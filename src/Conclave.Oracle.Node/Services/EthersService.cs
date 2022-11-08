namespace Conclave.Oracle.Node.Services;

public class EthersJSInteropService : BaseInteropService
{
    private readonly BrowserService _browserService;
    public event EventHandler? RandomEvent;

    public EthersJSInteropService(BrowserService browserService) : base(browserService)
    {
        _browserService = browserService;
        _ = ExposeFunctionAsync("csharp", ExposedFunction);
    }

    public void ExposedFunction()
    {
        RandomEvent?.Invoke(this, EventArgs.Empty);
    }

    public async Task<bool> IsDelegatedAsync(string privateKey, string contractAddress)
    {
        return await _browserService.InvokeFunctionAsync<bool>("IsDelegatedAsync", privateKey, contractAddress);
    }

    public async Task<string[]?> GetPendingRequestsAsync(string privateKey, string contractAddress)
    {
        return await _browserService.InvokeFunctionAsync<string[]>("GetPendingRequestsAsync", privateKey, contractAddress);
    }

    public async Task SubmitResultAsync(string privateKey, string contractAddress, string requestId, ulong[] decimals)
    {
        await _browserService.InvokeFunctionAsync("SubmitResultAsync", privateKey, contractAddress, requestId, decimals);
    }

    public async Task ListenToContractEventAsync(string contractAddress, string eventName)
    {
        await _browserService.InvokeFunctionAsync("SubmitResultAsync", contractAddress, eventName);
    }

    // public async Task Expose
}