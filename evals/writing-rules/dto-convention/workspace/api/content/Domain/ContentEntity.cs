using ContentApi.Services.CosmosDb;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ContentApi.Domain;

public class ContentEntity : CosmosDbEntity
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

    [JsonExtensionData]
    public Dictionary<string, JToken>? ExtensionData { get; set; }
}
