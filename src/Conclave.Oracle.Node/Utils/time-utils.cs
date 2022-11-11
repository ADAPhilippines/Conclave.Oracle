namespace Conclave.Oracle.Node.Utils;

public static class TimeUtils
{
    public static int UnixTimeToSlot(ulong unixTime)
    {
        ulong timePassed = (unixTime - 1666656000000);
        double slotsPassed = Math.Floor((float)(timePassed / 1000));
        return (int)(slotsPassed + 0);
    }
}

// int unixTimeToSlot(
//   unixTime: UnixTime,
//   slotConfig: SlotConfig,
// ): Slot {
//   const timePassed = (unixTime - slotConfig.zeroTime);
//   const slotsPassed = Math.floor(timePassed / slotConfig.slotLength);
//   return slotsPassed + slotConfig.zeroSlot;
// }