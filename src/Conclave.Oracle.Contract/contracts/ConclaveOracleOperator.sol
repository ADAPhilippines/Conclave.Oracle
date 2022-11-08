// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IConclaveOracleOperator.sol";
import "./interfaces/IStakeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConclaveOracleOperator is IConclaveOracleOperator, IStakeable {
    /* STAKING PROPERTIES */
    IERC20 private immutable _token;
    uint256 public s_minValidatorStake;
    mapping(address => uint256) private s_stakes;

    /* VALIDATOR NODE PROPERTIES */
    struct ValidatorNode {
        address owner;
        address node;
    }

    /* ORACLE PROPERTIES */
    struct JobRequest {
        uint256 jobId;
        uint256 adaFee;
        uint256 tokenFee;
        address requester;
        uint32 numCount;
        uint32 responseCount;
        uint64 timestamp;
        address[] validators;
        bool isFulfilled;
        uint256 result; /* data ID result */
        mapping(address => uint256) /* validator => dataId */ validatorDataId; 
        mapping(address => uint256) /* validator => stakeSnapshot */ validatorStakeSnapshot;
        mapping(uint256 => uint32) /* dataId => votes */ dataIdVotes;
        mapping(address => uint256) /* validator => adaReward */ adaRewards;
        mapping(address => uint256) /* validator => tokenReward */ tokenRewards;
        mapping(address => uint256) /* validator => minAdaReward */ validatorMinAdaReward;
        mapping(address => uint256) /* validator => minTokenReward */ validatorMinTokenReward;
        mapping(address => bool) /* validator => registered */ validatorRegistrations;
    }

    mapping(uint256 => uint256[]) /* dataId => random numbers */
        private s_jobRandomNumbers;

    mapping(uint256 => JobRequest)/* jobId => jobRequest */ private s_jobRequests;

    modifier isValidAmount(uint256 amount) {
        require(
            amount > 0,
            "ConclaveOracleOperator: Amount must be greater than 0"
        );
        _;
    }

    error InsufficientAllowance(uint256 required, uint256 actual);
    error InsufficientBalance(uint256 requested, uint256 balance);

    constructor(IERC20 token, uint256 minValidatorStake) {
        _token = token;
        s_minValidatorStake = minValidatorStake;
    }

    function delegateNode(address node) external override {}

    function acceptJob(
        uint256 jobId,
        uint256 minFeeReward,
        uint256 minTokenFeeReward
    ) external override {}

    function submitResponse(uint256 jobIb, uint256[] calldata response)
        external
        override
    {}

    function getJobDetails(uint256 jobId)
        external
        view
        override
        returns (
            uint256 fee,
            uint256 tokenFee,
            uint256 numCount,
            uint256 acceptanceTimeLimit,
            address[] memory validators
        )
    {}

    function distributeRewards(uint256 jobId) external override {}

    function getOracleFees()
        external
        view
        override
        returns (uint256 fee, uint256 tokenFee)
    {}

    function isJobReady(uint256 jobId) external view override returns (bool) {}

    function isResponseSubmitted(uint256 jobId)
        external
        view
        override
        returns (bool)
    {}

    function getRewards(uint256 jobId)
        external
        view
        override
        returns (uint256 reward, uint256 tokenReward)
    {}

    function getTotalRewards()
        external
        view
        override
        returns (uint256 reward, uint256 tokenReward)
    {}

    function stake(uint256 amount) external override isValidAmount(amount) {
        _token.transferFrom(msg.sender, address(this), amount);
        s_stakes[msg.sender] += amount;
    }

    function unstake(uint256 amount) external override isValidAmount(amount) {
        if (amount > s_stakes[msg.sender]) {
            revert InsufficientBalance(amount, s_stakes[msg.sender]);
        }

        s_stakes[msg.sender] -= amount;
        _token.transfer(msg.sender, amount);
    }

    function getStake(address account)
        external
        view
        override
        returns (uint256)
    {
        return s_stakes[account];
    }
}
