using Conclave.Oracle.Node.Interfaces;

namespace Conclave.Oracle.Node.Models;

public class NetworkBase : INetwork
{
    public ulong ZeroTime { get; set; }
    public ulong ZeroSlot { get; set; }
    public ulong SlotLength { get; set; }

    public NetworkBase(ulong zeroTime, ulong zeroSlot, ulong slotLength)
    {
        ZeroTime = zeroTime;
        ZeroSlot = zeroSlot;
        SlotLength = slotLength;
    }

    public int UnixTimeMsToSlot(ulong unixTimeMs)
    {
        ulong timePassed = (unixTimeMs - ZeroTime);
        double slotsPassed = Math.Floor((float)(timePassed / SlotLength));
        return (int)(slotsPassed + ZeroSlot);
    }
}