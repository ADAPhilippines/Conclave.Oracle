using System.Text.Json;

namespace Conclave.Oracle.Node.Settings;

public class SettingsServices
{
    public string privateKey { get; }= string.Empty;
    public string contractAddress { get; }= string.Empty;

    public SettingsServices()
    {
        string fileName = "./settings.json";
        string jsonString = File.ReadAllText(fileName);
        SettingsParameters parameters = JsonSerializer.Deserialize<SettingsParameters>(jsonString)!;

        privateKey = Environment.GetEnvironmentVariable(parameters.ENV_PrivateKey)!;
        contractAddress = Environment.GetEnvironmentVariable(parameters.ENV_ContractAddress)!;
    }
}