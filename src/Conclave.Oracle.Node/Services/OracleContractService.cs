using Conclave.Oracle.Node.Models;
using Conclave.Oracle.Node.Interfaces;
using Microsoft.Extensions.Options;
using Conclave.Oracle.Node.Utils;
using Conclave.Oracle.Node.Constants;

namespace Conclave.Oracle.Node.Services;

public class OracleContractService : ContractBase, IBrowserService
{
    private readonly ILogger<OracleContractService> _logger;
    private readonly BrowserService _browserService;
    public event EventHandler<RequestModel> RequestCreatedEvent;
    private readonly CardanoServices _blockfrostService;

    public OracleContractService(
        ILogger<OracleContractService> logger,
        BrowserService browserService,
        IOptions<SettingsParameters> settings,
        CardanoServices blockFrostService) : base(settings.Value.ContractAddress, settings.Value.PrivateKey)
    {
        _blockfrostService = blockFrostService;
        _logger = logger;
        _browserService = browserService;
        RequestCreatedEvent += async (sender, e) =>
        {
            _logger.LogInformation($"Received request {e.RequestId}");
            int slot = NetworkConstants.Preview.UnixTimeMsToSlot(UInt64.Parse(e.Timestamp));

            _logger.LogInformation(slot.ToString());
            int _slot = 1240682;
            string blockhash = await _blockfrostService.GetBlockHashFromSlot(_slot);
            Console.WriteLine(blockhash);
            string decimalValue = StringUtils.HexToDecimal(blockhash);
            Console.WriteLine(decimalValue);
            await SubmitResultAsync(e.RequestId, decimalValue);
            _logger.LogInformation($"RequestId {e.RequestId} Submitted");
        };
    }

    public RequestModel RequestNumbers(string requestId, string timeslot)
    {
        RequestModel req = new(requestId, timeslot);
        RequestCreatedEvent?.Invoke(this, new RequestModel(requestId, timeslot));
        return req;
    }

    public async Task<bool> IsDelegatedAsync()
    {
        return await _browserService.InvokeFunctionAsync<bool>("IsDelegatedAsync", PrivateKey, ContractAddress);
    }

    public async Task<List<BigNumberModel>?> GetPendingRequestsAsync()
    {
        return await _browserService.InvokeFunctionAsync<List<BigNumberModel>>("GetPendingRequestsAsync", PrivateKey, ContractAddress);
    }

    public async Task SubmitResultAsync(string requestId, string decimals)
    {
        await _browserService.InvokeFunctionAsync("SubmitResultAsync", PrivateKey, ContractAddress, requestId, decimals);
    }

    public async Task ListenToRequestCreatedEventAsync()
    {
        await _browserService.InvokeFunctionAsync("ListenToRequestCreatedEventAsync", ContractAddress);
    }

    public async Task WaitBrowserReadyAsync()
    {
        await _browserService.WaitBrowserReadyAsync();
    }

    public async Task ExposeRequestTrigger(string functionName, Func<string, string, RequestModel> function)
    {
        await _browserService.ExposeFunctionAsync<string, string, RequestModel>(functionName, function);
        _logger.LogInformation($"Waiting for function {functionName} to be exposed...");
        await _browserService.WaitFunctionReadyAsync(functionName);
        _logger.LogInformation($"function {functionName} is exposed...");
    }

    public async Task CallEvent(string functioname)
    {
        await WaitBrowserReadyAsync();
        await _browserService.WaitFunctionReadyAsync(functioname);
        await _browserService.InvokeFunctionAsync(functioname, "131213", "1668090827832");
    }
}