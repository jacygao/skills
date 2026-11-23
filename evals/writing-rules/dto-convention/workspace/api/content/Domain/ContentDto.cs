using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ContentApi.Domain;

public class ContentDto
{
    [JsonProperty("id")]
    public string Id { get; set; } = string.Empty;

    [JsonProperty("userId")]
    public string UserId { get; set; } = string.Empty;

    [JsonProperty("contentType")]
    public string ContentType { get; set; } = string.Empty;

    [JsonProperty("createdAt")]
    public long CreatedAt { get; set; }

    [JsonProperty("updatedAt")]
    public long UpdatedAt { get; set; }

    [JsonProperty("_deleted")]
    public bool Deleted { get; set; }

    [JsonProperty("serverEtag", NullValueHandling = NullValueHandling.Ignore)]
    public string? ServerEtag { get; set; }

    [JsonExtensionData]
    public Dictionary<string, JToken>? ExtensionData { get; set; }

    public static ContentDto FromEntity(ContentEntity entity) => new()
    {
        Id = entity.Id,
        UserId = entity.UserId,
        ContentType = entity.ContentType,
        CreatedAt = entity.CreatedAt,
        UpdatedAt = entity.UpdatedAt,
        Deleted = entity.Deleted,
        ServerEtag = entity.ETag,
        ExtensionData = ClientFields(entity.ExtensionData),
    };

    public static void ClearServerFields(ContentEntity incoming)
    {
        incoming.Timestamp = 0;
        incoming.ETag = null;
        incoming.ResourceId = null;
        incoming.Self = null;
        incoming.Attachments = null;
        incoming.ExtensionData = ClientFields(incoming.ExtensionData);
    }

    private static Dictionary<string, JToken>? ClientFields(Dictionary<string, JToken>? fields) =>
        fields?
            .Where(field => !IsServerField(field.Key))
            .ToDictionary(field => field.Key, field => field.Value);

    private static bool IsServerField(string name) =>
        name == "serverEtag" || (name.StartsWith('_') && name != "_deleted");
}
