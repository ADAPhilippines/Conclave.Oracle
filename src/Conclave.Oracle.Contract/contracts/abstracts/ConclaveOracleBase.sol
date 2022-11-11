// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/IConclaveOracle.sol";

abstract contract ConclaveOracleBase is IConclaveOracle {
    constructor() {}

    function fulfillRandomNumbers(uint256 jobId) external override {}

    function createJobRequest(
        uint256 numCount,
        uint256 fee,
        uint256 tokenFee
    ) external override {}

    function _calculateOracleFees() internal virtual;

    function _distributeRewards(uint256 jobId) internal virtual;
}
