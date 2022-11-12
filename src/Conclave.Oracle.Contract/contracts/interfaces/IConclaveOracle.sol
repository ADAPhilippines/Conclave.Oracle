// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IConclaveOracle {
    function requestRandomNumbers(
        uint32 numCount,
        uint256 fee,
        uint256 feePerNum,
        uint256 tokenFee,
        uint256 tokenFeePerNum
    ) external payable returns (uint256 jobId);
}
