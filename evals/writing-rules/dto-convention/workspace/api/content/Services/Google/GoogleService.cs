using Google.Apis.Auth;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;

namespace ContentApi.Services.Google;

public interface IGoogleService
{
    /// <summary>
    /// Verifies a Google OAuth access token and returns the user's profile.
    /// Returns null if the token is invalid or expired.
    /// </summary>
    Task<GoogleUserInfo?> GetUserInfoAsync(string accessToken);

    /// <summary>
    /// Validates a Google Identity Services (GIS) ID token and returns the user's profile.
    /// Requires GoogleOptions:ClientId to be configured — throws if missing.
    /// Returns null if the token is invalid or lacks an email claim.
    /// </summary>
    Task<GoogleUserInfo?> ValidateIdTokenAsync(string idToken);

    /// <summary>
    /// Exchanges a Google authorization code for tokens and returns the user's profile.
    /// Returns null if the exchange fails or the returned ID token is invalid.
    /// </summary>
    Task<GoogleUserInfo?> ExchangeAuthorizationCodeAsync(string code, string redirectUri);
}

public class GoogleUserInfo
{
    public string Id { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool VerifiedEmail { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Picture { get; set; } = string.Empty;
}

public class GoogleService : IGoogleService
{
    private readonly ILogger<GoogleService> _logger;
    private readonly HttpClient _httpClient;
    private readonly string _clientId;
    private readonly string _clientSecret;

    public GoogleService(ILogger<GoogleService> logger, IHttpClientFactory httpClientFactory, IOptions<GoogleOptions> options)
    {
        _logger = logger;
        _httpClient = httpClientFactory.CreateClient();
        _clientId = options.Value.ClientId;
        _clientSecret = options.Value.ClientSecret;
    }

    public async Task<GoogleUserInfo?> GetUserInfoAsync(string accessToken)
    {
        var response = await _httpClient.GetAsync(
            $"https://www.googleapis.com/oauth2/v1/userinfo?access_token={Uri.EscapeDataString(accessToken)}");

        if (!response.IsSuccessStatusCode)
        {
            var error = await response.Content.ReadAsStringAsync();
            _logger.LogWarning("Google userinfo request failed: {StatusCode}, {Error}", response.StatusCode, error);
            return null;
        }

        var raw = JsonConvert.DeserializeObject<GoogleUserInfoResponse>(
            await response.Content.ReadAsStringAsync());

        if (raw == null || string.IsNullOrEmpty(raw.Email))
            return null;

        return new GoogleUserInfo
        {
            Id = raw.Id,
            Email = raw.Email,
            VerifiedEmail = raw.VerifiedEmail,
            Name = raw.Name,
            Picture = raw.Picture,
        };
    }

    public async Task<GoogleUserInfo?> ValidateIdTokenAsync(string idToken)
    {
        if (string.IsNullOrEmpty(_clientId))
            throw new InvalidOperationException("Google Client ID is not configured. Set GoogleOptions:ClientId.");

        var settings = new GoogleJsonWebSignature.ValidationSettings
        {
            Audience = new[] { _clientId }
        };

        GoogleJsonWebSignature.Payload payload;
        try
        {
            payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);
        }
        catch (InvalidJwtException ex)
        {
            _logger.LogWarning("GIS ID token validation failed: {Message}", ex.Message);
            return null;
        }

        if (string.IsNullOrEmpty(payload.Email))
            return null;

        return new GoogleUserInfo
        {
            Id = payload.Subject,
            Email = payload.Email,
            VerifiedEmail = payload.EmailVerified,
            Name = payload.Name,
            Picture = payload.Picture,
        };
    }

    public async Task<GoogleUserInfo?> ExchangeAuthorizationCodeAsync(string code, string redirectUri)
    {
        if (string.IsNullOrEmpty(_clientSecret))
            throw new InvalidOperationException("Google Client Secret is not configured. Set GoogleOptions:ClientSecret.");

        var tokenRequest = new FormUrlEncodedContent(new[]
        {
            new KeyValuePair<string, string>("code", code),
            new KeyValuePair<string, string>("client_id", _clientId),
            new KeyValuePair<string, string>("client_secret", _clientSecret),
            new KeyValuePair<string, string>("redirect_uri", redirectUri),
            new KeyValuePair<string, string>("grant_type", "authorization_code"),
        });

        var response = await _httpClient.PostAsync("https://oauth2.googleapis.com/token", tokenRequest);
        if (!response.IsSuccessStatusCode)
        {
            var error = await response.Content.ReadAsStringAsync();
            _logger.LogWarning("Google token exchange failed: {StatusCode}, {Error}", response.StatusCode, error);
            return null;
        }

        var tokenResponse = JsonConvert.DeserializeObject<GoogleTokenResponse>(
            await response.Content.ReadAsStringAsync());

        if (string.IsNullOrEmpty(tokenResponse?.IdToken))
            return null;

        return await ValidateIdTokenAsync(tokenResponse.IdToken);
    }
}

internal class GoogleTokenResponse
{
    [JsonProperty("id_token")]
    public string? IdToken { get; set; }
}

internal class GoogleUserInfoResponse
{
    [JsonProperty("id")]
    public string Id { get; set; } = string.Empty;

    [JsonProperty("email")]
    public string Email { get; set; } = string.Empty;

    [JsonProperty("verified_email")]
    public bool VerifiedEmail { get; set; }

    [JsonProperty("name")]
    public string Name { get; set; } = string.Empty;

    [JsonProperty("picture")]
    public string Picture { get; set; } = string.Empty;
}
