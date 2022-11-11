// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./abstracts/ConclaveOracleBase.sol";
import "./ConclaveOracleOperator.sol";

contract ConclaveOracle is ConclaveOracleBase, ConclaveOracleOperator {
    constructor(IERC20 token, uint256 minValidatorStake)
        ConclaveOracleOperator(token, minValidatorStake)
    {}

    function calculateOracleFees() internal virtual override {}

    function distributeRewards(uint256 jobId) internal virtual override {}
}
