namespace Conclave.Oracle.Node.Interfaces;

public interface INetwork
{
    ulong ZeroTime { get; set; }
    ulong ZeroSlot { get; set; }
    ulong SlotLength { get; set; }

    int UnixTimeMsToSlot(ulong unixTimeMs);
}