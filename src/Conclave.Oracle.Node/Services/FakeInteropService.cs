namespace Conclave.Oracle.Node.Services;

public class FakeInteropService : BaseInteropService
{
    private readonly BrowserService _browserService;
    public event EventHandler? RandomEvent;

    public FakeInteropService(BrowserService browserService) : base(browserService)
    {
        _browserService = browserService;
        _ = ExposeFunctionAsync("csharp", ExposedFunction);
    }

    public void ExposedFunction()
    {
        RandomEvent?.Invoke(this, EventArgs.Empty);
    }

    public async Task<ulong> TimestampNowAsync()
    {
        return await _browserService.InvokeFunctionAsync<ulong>("timestampNow");
    }
}