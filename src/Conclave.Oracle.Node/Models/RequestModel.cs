namespace Conclave.Oracle.Node.Models;

public class RequestModel
{
    public string RequestId { get; set; }
    public string Timestamp { get; set; }

    public RequestModel(string requestId, string timestamp)
    {
        RequestId = requestId;
        Timestamp = timestamp;
    }
}