namespace Conclave.Oracle.Node.Interfaces;

interface IContract
{
    string ContractAddress { get; }
    string PrivateKey { get; }
}