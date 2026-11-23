using ContentApi.Domain;
using Newtonsoft.Json;

namespace ContentApi.Application.Sync;

public class Checkpoint
{
    [JsonProperty("updatedAt")]
    public long UpdatedAt { get; set; } = 0;

    [JsonProperty("id")]
    public string Id { get; set; } = "";
}

public class PullRequest
{
    [JsonProperty("checkpoint")]
    public Checkpoint Checkpoint { get; set; } = new();

    [JsonProperty("batchSize")]
    public int BatchSize { get; set; } = 100;
}

public class PullResponse
{
    [JsonProperty("documents")]
    public List<ContentDto> Documents { get; set; } = new();

    [JsonProperty("checkpoint")]
    public Checkpoint Checkpoint { get; set; } = new();
}

public class PushRow
{
    [JsonProperty("newDocumentState")]
    public ContentEntity NewDocumentState { get; set; } = null!;

    [JsonProperty("assumedMasterState")]
    public ContentEntity? AssumedMasterState { get; set; }
}
