using ContentApi.Application.Auth;
using ContentApi.Services.Firebase;
using ContentApi.Services.Foundry;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.ClientModel;

namespace ContentApi.Application.Ai;

public class AiController : AuthenticatedControllerBase
{
    private readonly IFoundryService _foundryService;

    public AiController(
        ILogger<AiController> logger,
        IFirebaseAdminService firebaseAdmin,
        IFoundryService foundryService)
        : base(logger, firebaseAdmin)
    {
        _foundryService = foundryService;
    }

    [Function("Completion")]
    public async Task<IActionResult> Completion(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", "options", Route = "ai/completion")] HttpRequest req)
    {
        if (req.Method == "OPTIONS")
        {
            return new OkResult();
        }

        _logger.LogInformation("Completion request received");

        try
        {
            await GetCurrentUserIdAsync(req);

            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var request = JsonConvert.DeserializeObject<CompletionRequest>(requestBody);

            if (request?.Messages is not { Count: > 0 })
            {
                return new BadRequestObjectResult(new { error = "Messages is required" });
            }

            var preset = PresetRegistry.Resolve(request.Preset);
            var systemMessage = SystemMessageBuilder.Build(
                preset.SystemPrompt ?? "You are a helpful AI assistant.",
                request.CustomInstruction,
                request.AttachedContext);

            var text = await _foundryService.CompletionAsync(systemMessage, request.Messages, preset);
            return new OkObjectResult(new { text });
        }
        catch (UnauthorizedAccessException ex)
        {
            _logger.LogWarning(ex, "Unauthorized access attempt");
            return new UnauthorizedObjectResult(new { error = ex.Message });
        }
        catch (ClientResultException ex) when (ex.Status == 400)
        {
            _logger.LogWarning(ex, "AI service rejected the request");
            return new BadRequestObjectResult(new { error = "Request could not be processed. Please modify your input and try again." });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing completion request");
            return new StatusCodeResult(StatusCodes.Status500InternalServerError);
        }
    }

    [Function("CompletionStream")]
    public async Task CompletionStream(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", "options", Route = "ai/completion/stream")] HttpRequest req)
    {
        if (req.Method == "OPTIONS")
        {
            req.HttpContext.Response.StatusCode = 200;
            return;
        }

        _logger.LogInformation("CompletionStream request received");

        try
        {
            await GetCurrentUserIdAsync(req);

            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var request = JsonConvert.DeserializeObject<CompletionRequest>(requestBody);

            if (request?.Messages is not { Count: > 0 })
            {
                req.HttpContext.Response.StatusCode = 400;
                await req.HttpContext.Response.WriteAsync("{\"error\":\"Messages is required\"}");
                return;
            }

            var preset = PresetRegistry.Resolve(request.Preset);
            var systemMessage = SystemMessageBuilder.Build(
                preset.SystemPrompt ?? "You are a helpful AI assistant.",
                request.CustomInstruction,
                request.AttachedContext);

            req.HttpContext.Response.ContentType = "text/event-stream";
            req.HttpContext.Response.Headers["Cache-Control"] = "no-cache";
            req.HttpContext.Response.Headers["Connection"] = "keep-alive";

            await foreach (var token in _foundryService.CompletionStreamAsync(systemMessage, request.Messages, preset, request.Tools))
            {
                string sseData;
                if (token.StartsWith(FoundryService.ToolCallsSentinel))
                    sseData = token[FoundryService.ToolCallsSentinel.Length..]; // already JSON
                else
                    sseData = JsonConvert.SerializeObject(token); // encode string as JSON

                await req.HttpContext.Response.WriteAsync($"data: {sseData}\n\n");
                await req.HttpContext.Response.Body.FlushAsync();
            }

            await req.HttpContext.Response.WriteAsync("data: [DONE]\n\n");
            await req.HttpContext.Response.Body.FlushAsync();
        }
        catch (UnauthorizedAccessException ex)
        {
            _logger.LogWarning(ex, "Unauthorized access attempt");
            req.HttpContext.Response.StatusCode = 401;
            await req.HttpContext.Response.WriteAsync("{\"error\":\"" + ex.Message + "\"}");
        }
        catch (ClientResultException ex) when (ex.Status == 400)
        {
            _logger.LogWarning(ex, "AI service rejected the request");
            req.HttpContext.Response.StatusCode = 400;
            await req.HttpContext.Response.WriteAsync("{\"error\":\"Request could not be processed. Please modify your input and try again.\"}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing completion stream request");
            if (!req.HttpContext.Response.HasStarted)
            {
                req.HttpContext.Response.StatusCode = 500;
            }
        }
    }

    [Function("Embed")]
    public async Task<IActionResult> Embed(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", "options", Route = "ai/embed")] HttpRequest req)
    {
        if (req.Method == "OPTIONS")
        {
            return new OkResult();
        }

        _logger.LogInformation("Embed request received");

        try
        {
            await GetCurrentUserIdAsync(req);

            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var request = JsonConvert.DeserializeObject<EmbedRequest>(requestBody);

            if (request?.Texts is not { Count: > 0 })
            {
                return new BadRequestObjectResult(new { error = "Texts is required" });
            }

            var vectors = await _foundryService.EmbedAsync(request.Texts);

            return new OkObjectResult(new { vectors });
        }
        catch (UnauthorizedAccessException ex)
        {
            _logger.LogWarning(ex, "Unauthorized access attempt");
            return new UnauthorizedObjectResult(new { error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing embed request");
            return new StatusCodeResult(StatusCodes.Status500InternalServerError);
        }
    }
}

public class CompletionRequest
{
    public required List<ChatMessageDto> Messages { get; set; }
    public string? CustomInstruction { get; set; }
    public string? Preset { get; set; }
    public List<ToolDefinitionDto>? Tools { get; set; }
    public Dictionary<string, string>? AttachedContext { get; set; }
}

public class EmbedRequest
{
    public required List<string> Texts { get; set; }
}
