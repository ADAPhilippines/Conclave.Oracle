using Conclave.Oracle.Node.Services;

namespace Conclave.Oracle;

public class OracleWorker : IHostedService
{
    private readonly ILogger<OracleWorker> _logger;
    private readonly FakeInteropService _fakeInteropService;

    public OracleWorker(ILogger<OracleWorker> logger, FakeInteropService fakeInteropService)
    {
        _logger = logger;
        _fakeInteropService = fakeInteropService;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _ = Task.Run(async () =>
        {
            await _fakeInteropService.WaitBrowserReadyAsync();
            _fakeInteropService.RandomEvent += async (sender, e) => {
                ulong timestamp = await _fakeInteropService.TimestampNowAsync();
                _logger.LogInformation($"Fake Result {timestamp}");
            };
            _logger.LogInformation("Oracle Node Started...");
        });
    }

    public async Task StopAsync(CancellationToken cancellationToken)
    {

    }
}