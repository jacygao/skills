using Newtonsoft.Json;

namespace ContentApi.Application.Auth;

// -------------------------------------------------------------------------
// Domain model — populated by FirebaseAdminService.ValidateTokenAsync
// -------------------------------------------------------------------------

public class AuthenticatedUser
{
    public string Uid { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Picture { get; set; } = string.Empty;
    public bool EmailVerified { get; set; }
    public string? ProviderId { get; set; }
}

// -------------------------------------------------------------------------
// Internal Apple OAuth helpers
// -------------------------------------------------------------------------

internal class AppleUserJson
{
    [JsonProperty("name")]
    public AppleUserName? Name { get; set; }
}

internal class AppleUserName
{
    [JsonProperty("firstName")]
    public string? FirstName { get; set; }

    [JsonProperty("lastName")]
    public string? LastName { get; set; }
}

// -------------------------------------------------------------------------
// Request DTOs
// -------------------------------------------------------------------------

public class AuthenticateRequest
{
    [JsonProperty("firebaseToken")]
    public string FirebaseToken { get; set; } = string.Empty;
}

public class ExchangeCustomTokenRequest
{
    [JsonProperty("customToken")]
    public string CustomToken { get; set; } = string.Empty;
}

public class RefreshTokenRequest
{
    [JsonProperty("refreshToken")]
    public string RefreshToken { get; set; } = string.Empty;
}

public class SendEmailLinkRequest
{
    [JsonProperty("email")]
    public string Email { get; set; } = string.Empty;

    [JsonProperty("continueUrl")]
    public string ContinueUrl { get; set; } = string.Empty;
}

// -------------------------------------------------------------------------
// Response DTOs
// -------------------------------------------------------------------------

public class UserResponse
{
    [JsonProperty("id")]
    public string Id { get; set; } = string.Empty;

    [JsonProperty("email")]
    public string? Email { get; set; }

    [JsonProperty("name")]
    public string Name { get; set; } = string.Empty;

    [JsonProperty("picture")]
    public string Picture { get; set; } = string.Empty;

    [JsonProperty("aiCredit")]
    public int AiCredit { get; set; }
}

public class AuthenticateResponse
{
    [JsonProperty("user")]
    public UserResponse User { get; set; } = new();

    [JsonProperty("token")]
    public string Token { get; set; } = string.Empty;
}

public class AuthWithRefreshResponse
{
    [JsonProperty("user")]
    public UserResponse User { get; set; } = new();

    [JsonProperty("token")]
    public string Token { get; set; } = string.Empty;

    [JsonProperty("refreshToken")]
    public string RefreshToken { get; set; } = string.Empty;

    [JsonProperty("expiresIn")]
    public int ExpiresIn { get; set; }
}

public class TokenRefreshResponse
{
    [JsonProperty("token")]
    public string Token { get; set; } = string.Empty;

    [JsonProperty("refreshToken")]
    public string RefreshToken { get; set; } = string.Empty;

    [JsonProperty("expiresIn")]
    public int ExpiresIn { get; set; }
}
