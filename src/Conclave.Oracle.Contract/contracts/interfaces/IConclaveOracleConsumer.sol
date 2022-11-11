// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IConclaveOracleConsumer {
    /** fulfilling random numbers that can only be called by the conclave random number coordinator **/
    function rawFulfillRandomNumbers(
        uint256 requestId,
        uint256[] memory randomNumbers
    ) external;
}
