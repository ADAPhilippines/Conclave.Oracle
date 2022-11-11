// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IConclaveOracleOperator.sol";
import "./Staking.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConclaveOracleOperator is IConclaveOracleOperator, Staking {

    error InsufficientAllowance(uint256 required, uint256 actual);
    error RequestNotExist();
    error RequestAlreadyFulfilled();
    error ResponseSubmissionNotAuthorized();
    error ResponseAlreadySubmitted();
    error NodeAlreadyRegistered();
    error NodeRegisteredToAdifferentOperator(address registeredOperator);
    error NotEnoughStake(uint256 required, uint256 actual);
    error TimeLimitExceeded(uint256 timeLimit, uint256 actual);

    modifier onlyExistingRequest(uint256 jobId) {
        if (s_jobRequests[jobId].requester == address(0)) {
            revert RequestNotExist();
        }
        _;
    }

    modifier onlyValidator() {
        if (s_stakes[s_nodeToOwner[msg.sender]] < s_minStake) {
            revert NotEnoughStake(s_minStake, s_stakes[s_nodeToOwner[msg.sender]]);
        }
        _;
    }

    modifier onlyUnfilfilledRequests(uint256 jobId) {
        if (s_jobRequests[jobId].isFulfilled) {
            revert RequestAlreadyFulfilled();
        }
        _;
    }

    modifier onlyWithinTimeLimit(uint64 timelimit) {
        if (block.timestamp > timelimit) {
            revert TimeLimitExceeded(timelimit, block.timestamp);
        }
        _;
    }

    event JobAccepted(uint256 indexed jobId, address indexed node, uint64 jobAcceptanceExpiration);
    event ResponseSubmitted(uint256 indexed jobId, address indexed requester, uint256 totalResponseExpected, uint256 currentResponse);

    struct Rewards {
        uint256 ada;
        uint256 token;
    }

    /* ORACLE PROPERTIES */
    struct JobRequest {
        uint256 jobId;
        uint256 adaFee;
        uint256 tokenFee;
        address requester;
        uint256 responseCount;
        uint24 numCount;
        uint64 timestamp;
        uint64 jobAcceptanceExpiration;
        uint64 jobFulfillmentExpiration;
        address[] validators;
        bool isFulfilled;
        uint256 finalResultDataId; /* data ID result */
        mapping(address => uint256) /* node => dataId */ nodeDataId; 
        mapping(uint256 => uint32) /* dataId => votes */ dataIdVotes;
        mapping(address => uint256) /* node => adaReward */ adaRewards;
        mapping(address => uint256) /* node => tokenReward */ tokenRewards;
        mapping(address => uint256) /* node => minAdaReward */ nodeMinAdaReward;
        mapping(address => uint256) /* node => minTokenReward */ nodeMinTokenReward;
        mapping(address => bool) /* node => isRegistered */ nodeRegistrations;
    }

    mapping(uint256 => uint256[]) /* dataId => random numbers */
        private s_jobRandomNumbers;

    mapping(uint256 => JobRequest)/* jobId => jobRequest */ private s_jobRequests;
    mapping(address => Rewards) /* validator => rewards */ private s_validatorRewards;
    mapping(address => address) /* owner => node */ private s_ownerToNode;
    mapping(address => address) /* node => owner */ private s_nodeToOwner;

    constructor(IERC20 token, uint256 minValidatorStake) Staking(token, minValidatorStake) {}

    function delegateNode(address node) external override {
        if (s_nodeToOwner[node] != msg.sender) {
            revert NodeRegisteredToAdifferentOperator(s_nodeToOwner[node]);
        }

        if (s_ownerToNode[msg.sender] == node) {
            revert NodeAlreadyRegistered();
        }

        s_ownerToNode[msg.sender] = node;
        s_nodeToOwner[node] = msg.sender;
    }

    function acceptJob(uint256 jobId, uint256 minFeeReward, uint256 minTokenFeeReward) 
        external 
        override 
        onlyExistingRequest(jobId) 
        onlyValidator 
        onlyUnfilfilledRequests(jobId)
        onlyWithinTimeLimit(s_jobRequests[jobId].jobAcceptanceExpiration)
    {
        JobRequest storage request = s_jobRequests[jobId];

        if (request.nodeRegistrations[msg.sender]) {
            revert NodeAlreadyRegistered();
        }

        request.nodeRegistrations[msg.sender] = true;
        request.nodeMinAdaReward[msg.sender] = minFeeReward;
        request.nodeMinTokenReward[msg.sender] = minTokenFeeReward;

        emit JobAccepted(jobId, msg.sender, request.jobAcceptanceExpiration);
    }

    function submitResponse(uint256 jobId, uint256[] calldata response)
        external
        override
        onlyExistingRequest(jobId)
        onlyValidator
        onlyUnfilfilledRequests(jobId)
        onlyWithinTimeLimit(s_jobRequests[jobId].jobFulfillmentExpiration)
    {
        JobRequest storage request = s_jobRequests[jobId];

        if (!request.nodeRegistrations[msg.sender]) {
            revert ResponseSubmissionNotAuthorized();
        }

        if (request.nodeDataId[msg.sender] != 0) {
            revert ResponseAlreadySubmitted();
        }

        uint256 dataId = uint256(keccak256(abi.encode(jobId, response, request.timestamp, request.requester)));
        request.nodeDataId[msg.sender] = dataId;
        request.responseCount += 1;
        request.dataIdVotes[dataId] += 1;

        emit ResponseSubmitted(jobId, request.requester, request.validators.length, request.responseCount);
    }

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
    {
        return (
            s_jobRequests[jobId].adaFee,
            s_jobRequests[jobId].tokenFee,
            s_jobRequests[jobId].numCount,
            s_jobRequests[jobId].jobAcceptanceExpiration,
            s_jobRequests[jobId].validators
        );
    }

    function isJobReady(uint256 jobId) external view override returns (bool) {
        return block.timestamp > s_jobRequests[jobId].jobAcceptanceExpiration;
    }

    function isResponseSubmitted(uint256 jobId)
        external
        view
        override
        returns (bool)
    {
        return s_jobRequests[jobId].nodeDataId[msg.sender] != 0;
    }

    function getRewards(uint256 jobId)
        external
        view
        override
        returns (uint256, uint256)
    {
        return (s_jobRequests[jobId].adaRewards[msg.sender], s_jobRequests[jobId].tokenRewards[msg.sender]);
    }

    function getTotalRewards()
        external
        view
        override
        returns (uint256, uint256)
    {
        return (s_validatorRewards[msg.sender].ada, s_validatorRewards[msg.sender].token);
    }
}
