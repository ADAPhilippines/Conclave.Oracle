namespace Conclave.Oracle.Node.Services;


interface IBaseInteropService
{
    public Task WaitBrowserReadyAsync();
    public Task ExposeFunctionAsync(string name, Action f);
}

public class BaseInteropService : IBaseInteropService
{
    private readonly BrowserService _browserService;

    public BaseInteropService(BrowserService browserService)
    {
        _browserService = browserService;
    }

    public async Task WaitBrowserReadyAsync()
    {
        while (!_browserService.IsInitialized) await Task.Delay(1000);
    }

    public async Task ExposeFunctionAsync(string name, Action f)
    {
        await WaitBrowserReadyAsync();
        await _browserService.ExposeFunction(name, f);
    }
}