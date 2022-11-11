// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IConclaveOracle {
    function fulfillRandomNumbers(uint256 jobId) external;

    function createJobRequest(
        uint256 numCount,
        uint256 fee,
        uint256 tokenFee
    ) external;
}
