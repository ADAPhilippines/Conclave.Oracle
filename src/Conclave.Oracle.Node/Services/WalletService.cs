using Conclave.Oracle.Node.Models;
using Microsoft.Extensions.Options;

namespace Conclave.Oracle.Node.Services;

public class WalletService
{
    public readonly string PrivateKey = string.Empty;
    public WalletService(IOptions<SettingsParameters> settings)
    {
        PrivateKey = settings.Value.PrivateKey;
    }
}