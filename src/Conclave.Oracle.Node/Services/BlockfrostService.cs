using Blockfrost.Api;
using Blockfrost.Api.Extensions;

namespace Conclave.Oracle.Node.Services;

public class BlockFrostService
{
    private readonly IBlockService _blockService;
    public BlockFrostService(IBlockService iblockService)
    {
        _blockService = iblockService;
    }

    public async Task<string> GetBlockHashFromSlot(int slot)
    {
        BlockContentResponse res = await _blockService.GetSlotAsync(slot);
        return res.Hash;
    }
}