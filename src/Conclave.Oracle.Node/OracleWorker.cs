using Conclave.Oracle.Node.Service;

namespace Conclave.Oracle;

public class OracleWorker : IHostedService
{
    private readonly ILogger<OracleWorker> _logger;
    private readonly BrowserService _browserService;
    
    public OracleWorker(ILogger<OracleWorker> logger, BrowserService browserService)
    {
        _logger = logger;
        _browserService = browserService;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Oracle Node Started...");
    }

    public async Task StopAsync(CancellationToken cancellationToken)
    {

    }
}