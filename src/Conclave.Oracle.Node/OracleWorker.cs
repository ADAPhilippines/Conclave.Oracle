using Conclave.Oracle.Node.Services;
using Conclave.Oracle.Node.Models;
using Blockfrost.Api;

namespace Conclave.Oracle;

public class OracleWorker : BackgroundService
{
    private readonly ILogger<OracleWorker> _logger;
    private readonly OracleContractService _oracleContractService;
    private readonly CardanoServices _blockFrostService;

    public OracleWorker(
        ILogger<OracleWorker> logger,
        OracleContractService oracleContractService,
        CardanoServices blockFrostService) : base()
    {
        _blockFrostService = blockFrostService;
        _logger = logger;
        _oracleContractService = oracleContractService;
    }

    protected async override Task ExecuteAsync(CancellationToken cancellationToken)
    {
        _ = Task.Run(async () =>
        {
            _logger.LogInformation("Starting Oracle Node...");
            await _oracleContractService.WaitBrowserReadyAsync();
            await _oracleContractService.ExposeRequestTrigger("requestnumbers", _oracleContractService.RequestNumbers);
            _logger.LogInformation("Oracle Node Started...");
            await CheckPrivateKeyDelegationAsync();
            //Check if Address from Private Key is Delegated
        });
    }

    public async Task CheckPrivateKeyDelegationAsync()
    {
        _logger.LogInformation("Checking address from PrivateKey is Delegated...");
        //Todo: Error Handling;
        bool isDelegated = await _oracleContractService.IsDelegatedAsync();

        if (isDelegated) _logger.LogInformation($"The Private Key Is Delegated!");
        else _logger.LogInformation($"The Private Key Is not Delegated. Please delegate");

        _ = Task.Run(async () =>
        {
            await GetPendingRequestsAsync();
        });

        _ = Task.Run(async () =>
        {
            await ListenToRequestAsync();
        });
    }

    public async Task GetPendingRequestsAsync()
    {
        _logger.LogInformation("Checking for pending Requests...");
        //Todo: Error Handling;
        List<BigNumberModel>? pendingRequests = await _oracleContractService.GetPendingRequestsAsync();
        _logger.LogInformation($"Number of Pending requests: {pendingRequests?.Count ?? 0}");
        // run process for generating number from blockhash        
    }

    public async Task ListenToRequestAsync()
    {
        _logger.LogInformation("Listening to contract events...");
        await _oracleContractService.ListenToRequestCreatedEventAsync();
        _logger.LogInformation("Currently Listening to Requests...");
    }
}