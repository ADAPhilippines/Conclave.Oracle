// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ConclaveOracleOperator.sol";
import "./interfaces/IConclaveOracle.sol";

contract ConclaveOracle is IConclaveOracle, ConclaveOracleOperator {
    uint32 s_minNumCount = 1;
    uint32 s_maxNumCount = 500;

    uint256 nonce;

    error ValueMismatch(uint256 stated, uint256 actual);
    error NumberCountNotInRange(uint256 min, uint256 max, uint256 actual);

    constructor(IERC20 token, uint256 minValidatorStake)
        ConclaveOracleOperator(token, minValidatorStake)
    {}

    function requestRandomNumbers(
        uint32 numCount,
        uint256 fee,
        uint256 feePerNum,
        uint256 tokenFee,
        uint256 tokenFeePerNum
    ) external payable returns (uint256 jobId) {
        uint256 totalFee = fee + (numCount * feePerNum);
        uint256 totalTokenFee = tokenFee + (numCount * tokenFeePerNum);

        if (msg.value != totalFee) {
            revert ValueMismatch(msg.value, totalFee);
        }

        if (numCount < s_minNumCount || numCount > s_maxNumCount) {
            revert NumberCountNotInRange(
                s_minNumCount,
                s_maxNumCount,
                numCount
            );
        }

        _token.transferFrom(msg.sender, address(this), totalTokenFee);
        jobId = _getJobId(msg.sender, numCount, block.timestamp, nonce);
    }

    function _fulfillRandomNumbers(uint256 jobId) internal {}

    function _createJobRequest(
        uint256 numCount,
        uint256 fee,
        uint256 tokenFee
    ) internal {}

    function _calculateOracleFees() internal {}

    function _distributeRewards(uint256 jobId) internal {}

    function _getJobId(
        address requester,
        uint256 numCount,
        uint256 timestamp,
        uint256 _nonce
    ) internal pure returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(requester, numCount, timestamp, _nonce)
                )
            );
    }

    receive() external payable {}
}
