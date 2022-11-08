using Conclave.Oracle.Node.Services;
using Conclave.Oracle.Node.Settings;

namespace Conclave.Oracle;

public class OracleWorker : IHostedService
{
    private readonly ILogger<OracleWorker> _logger;
    private readonly FakeInteropService _fakeInteropService;
    private readonly EthersJSInteropService _ethersJSInteropService;
    private readonly SettingsServices _settingsService;
    public OracleWorker(
        ILogger<OracleWorker> logger, 
        FakeInteropService fakeInteropService, 
        EthersJSInteropService ethersJSInteropService,
        SettingsServices settingsServices)
    {
        _logger = logger;
        _fakeInteropService = fakeInteropService;
        _ethersJSInteropService = ethersJSInteropService;
        _settingsService = settingsServices;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _ = Task.Run(async () =>
        {
            _logger.LogInformation("Starting Oracle Node...");
            await _ethersJSInteropService.WaitBrowserReadyAsync();
            // //ready to intereact with Browser data
            // _fakeInteropService.RandomEvent += async (sender, e) => {
            //     ulong timestamp = await _fakeInteropService.TimestampNowAsync();
            //     _logger.LogInformation($"Fake Result {timestamp}");
            // };
            _logger.LogInformation("Oracle Node Started...");
            await CheckPrivateKeyDelegationAsync();
            //Check if Address from Private Key is Delegated
        });
    }

    public async Task CheckPrivateKeyDelegationAsync()
    {
        _logger.LogInformation("Checking address from PrivateKey is Delegated...");
        //Todo: Error Handling;
        bool isDelegated = await _ethersJSInteropService.IsDelegatedAsync(_settingsService.privateKey, _settingsService.contractAddress);
        
        if (isDelegated) _logger.LogInformation($"The Address {_settingsService.contractAddress} Is Delegated!");
        else _logger.LogInformation($"The Address {_settingsService.contractAddress} Is Delegated. Please refer to this website");
        GetPendingRequestsAsync();
        ListenToRequestAsync();
    }

    public async Task GetPendingRequestsAsync()
    {
        _logger.LogInformation("Checking for pending Requests...");
        //Todo: Error Handling;
        string[]? pendingRequests = await _ethersJSInteropService.GetPendingRequestsAsync(_settingsService.privateKey, _settingsService.contractAddress);
        _logger.LogInformation($"Number of Pending requests: {pendingRequests?.Length ?? 0}");
        // should run in parallel with listener
        // run process for generating number from blockhash        
    }

    public async Task ListenToRequestAsync()
    {
        _logger.LogInformation("Listening to contract events...");
        await _ethersJSInteropService.ListenToContractEventAsync(_settingsService.contractAddress, "RequestCreated");
        _logger.LogInformation("Currently Listening to Requests...");
    }

    public async Task StopAsync(CancellationToken cancellationToken)
    {

    }
}