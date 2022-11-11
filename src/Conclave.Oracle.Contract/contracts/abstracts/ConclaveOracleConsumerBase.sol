// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IConclaveOracleConsumer {
    function requestRandomNumber(
        uint256 numCount,
        uint256 fee,
        uint256 tokenFee
    ) external;

    function getResponseCount(uint256 jobId)
        external
        view
        returns (uint256 currentResponses, uint256 totalResponses);

    function aggregateResponses(uint256 jobId) external;
}
