using Conclave.Oracle.Node.Interfaces;

namespace Conclave.Oracle.Node.Services;

public class ContractBase : IContract
{
    public string PrivateKey { get; } = string.Empty;
    public string ContractAddress { get; } = string.Empty;

    public ContractBase (string _contractAddress, string _privateKey)
    {
        ContractAddress = _contractAddress;
        PrivateKey = _privateKey;
    }
}