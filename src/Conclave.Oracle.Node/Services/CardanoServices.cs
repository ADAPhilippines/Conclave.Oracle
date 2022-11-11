using Blockfrost.Api;
using Blockfrost.Api.Extensions;
using System.Numerics;

namespace Conclave.Oracle.Node.Services;

public class CardanoServices
{
    private readonly IBlockService _blockService;
    public CardanoServices(IBlockService iblockService)
    {
        _blockService = iblockService;
    }

    public async Task<string> GetBlockHashFromSlot(int slot)
    {
        BlockContentResponse res = await _blockService.GetSlotAsync(slot);
        return res.Hash;
    }

    public async Task<string> GetNextBlockHashCurrentHash(string blockHash, int nextBlocks)
    {
        List<BlockContentResponse>? res = await _blockService.GetNextBlockAsync(blockHash, nextBlocks, 1) as List<BlockContentResponse>;
        return res?[0].Hash ?? string.Empty;
    }
}