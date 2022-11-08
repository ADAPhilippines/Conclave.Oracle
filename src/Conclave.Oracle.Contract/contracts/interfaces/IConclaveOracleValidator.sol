// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IStakeable} from "./IStakeable.sol";

interface IConclaveOracleValidator is IStakeable {
    function delegateNode(address node) external;

    function acceptJob(
        uint256 jobId,
        uint256 minFeeReward,
        uint256 minTokenFeeReward
    ) external;

    function submitResponse(uint256 jobIb, uint256[] calldata response)
        external;

    function getJobDetails(uint256 jobId)
        external
        view
        returns (
            uint256 fee,
            uint256 tokenFee,
            uint256 numCount,
            uint256 acceptanceTimeLimit,
            address[] memory validators
        );

    function getOracleFees()
        external
        view
        returns (uint256 fee, uint256 tokenFee);

    function isJobReady(uint256 jobId) external view returns (bool);

    function isResponseSubmitted(uint256 jobId) external view returns (bool);

    function getRewards(uint256 jobId)
        external
        view
        returns (uint256 reward, uint256 tokenReward);

    function getTotalRewards()
        external
        view
        returns (uint256 reward, uint256 tokenReward);
}
