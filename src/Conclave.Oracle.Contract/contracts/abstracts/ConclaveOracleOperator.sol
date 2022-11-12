// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/IConclaveOracleOperator.sol";
import "../Staking.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract ConclaveOracleOperator is IConclaveOracleOperator, Staking {

    error InsufficientAllowance(uint256 required, uint256 actual);
    error RequestNotExist();
    error RequestAlreadyFulfilled();
    error ResponseSubmissionNotAuthorized();
    error ResponseAlreadySubmitted();
    error NodeAlreadyRegistered();
    error NodeRegisteredToAdifferentOperator(address registeredOperator);
    error NotEnoughStake(uint256 required, uint256 actual);
    error TimeLimitExceeded(uint256 timeLimit, uint256 actual);
    error InvalidResponse(uint256 expected, uint256 actual);
    error MaxValidatorReached(uint256 maxValidator);
    error MinValidatorNotReached(uint256 minValidator);

    modifier onlyExistingRequest(uint256 jobId) {
        JobRequest storage request = _getJobRequest(jobId);
        if (request.requester == address(0)) {
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
        JobRequest storage request = _getJobRequest(jobId);
        if (request.isFulfilled) {
            revert RequestAlreadyFulfilled();
        }
        _;
    }

    modifier onlyWithinTimeLimit(uint256 timelimit) {
        if (block.timestamp > timelimit) {
            revert TimeLimitExceeded(timelimit, block.timestamp);
        }
        _;
    }

    event NodeRegistered(address indexed node, address indexed owner);
    event JobAccepted(uint256 indexed jobId, address indexed node, uint256 jobAcceptanceExpiration);
    event ResponseSubmitted(uint256 indexed jobId, address indexed requester, uint256 totalResponseExpected, uint256 currentResponse);

    struct Rewards {
        uint256 ada;
        uint256 token;
    }

    /* ORACLE PROPERTIES */
    struct JobRequest {
        uint256 jobId;
        uint256 baseAdaFee;
        uint256 baseTokenFee;
        uint256 adaFeePerNum;
        uint256 tokenFeePerNum;
        uint256 timestamp;
        uint256 jobAcceptanceExpiration;
        uint256 jobFulfillmentExpiration;
        uint256 finalResultDataId; /* data ID result */
        uint24 responseCount;
        uint24 numCount;
        bool isFulfilled;
        address requester;
        address[] validators;
        uint256[] dataIds;
        mapping(address => uint256) /* node => dataId */ nodeDataId; 
        mapping(uint256 => uint32) /* dataId => votes */ dataIdVotes;
        mapping(address => uint256) /* node => adaReward */ adaRewards;
        mapping(address => uint256) /* node => tokenReward */ tokenRewards;
        mapping(address => uint256) /* node => minAdaReward */ nodeMinAdaReward;
        mapping(address => uint256) /* node => minTokenReward */ nodeMinTokenReward;
        mapping(address => bool) /* node => isRegistered */ nodeRegistrations;
    }

    uint24 s_minValidator;
    uint24 s_maxValidator;

    mapping(uint256 => uint256[]) /* dataId => random numbers */ private s_jobRandomNumbers;
    mapping(address => Rewards) /* validator => rewards */ private s_validatorRewards;
    mapping(address => address) /* owner => node */ private s_ownerToNode;
    mapping(address => address) /* node => owner */ private s_nodeToOwner;

    constructor(IERC20 token, uint256 minValidatorStake, uint24 minValidator, uint24 maxValidator ) Staking(token, minValidatorStake) {
        s_minValidator = minValidator;
        s_maxValidator = maxValidator;
    }

    function delegateNode(address node) external override {
        if (s_nodeToOwner[node] != msg.sender) {
            revert NodeRegisteredToAdifferentOperator(s_nodeToOwner[node]);
        }

        if (s_ownerToNode[msg.sender] == node) {
            revert NodeAlreadyRegistered();
        }

        s_ownerToNode[msg.sender] = node;
        s_nodeToOwner[node] = msg.sender;

        emit NodeRegistered(node, msg.sender);
    }

    function acceptJob(uint256 jobId, uint256 minFeeReward, uint256 minTokenFeeReward) 
        external 
        override 
        onlyExistingRequest(jobId) 
        onlyValidator 
        onlyUnfilfilledRequests(jobId)
        onlyWithinTimeLimit(_getJobRequest(jobId).jobAcceptanceExpiration)
    {
        JobRequest storage request = _getJobRequest(jobId);

        if (request.nodeRegistrations[msg.sender]) {
            revert NodeAlreadyRegistered();
        }

        if (request.validators.length >= s_maxValidator) {
            revert MaxValidatorReached(s_maxValidator);
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
        onlyWithinTimeLimit(_getJobRequest(jobId).jobFulfillmentExpiration)
    {
        JobRequest storage request = _getJobRequest(jobId);

        if (!request.nodeRegistrations[msg.sender]) {
            revert ResponseSubmissionNotAuthorized();
        }

        if (request.nodeDataId[msg.sender] != 0) {
            revert ResponseAlreadySubmitted();
        }

        if (response.length != request.numCount) {
            revert InvalidResponse(request.numCount, response.length);
        }

        if (request.validators.length < s_minValidator) {
            revert MinValidatorNotReached(s_minValidator);
        }

        uint256 dataId = _getDataId(jobId, response, request.timestamp, request.requester);
        request.nodeDataId[msg.sender] = dataId;
        request.responseCount += 1;
        request.dataIdVotes[dataId] += 1;

        if (s_jobRandomNumbers[dataId].length == 0) {
            s_jobRandomNumbers[dataId] = response;
        }

        if (request.dataIdVotes[dataId] == 1) {
            request.dataIds.push(dataId);
        }

        emit ResponseSubmitted(jobId, request.requester, request.validators.length, request.responseCount);
    }

    function getJobDetails(uint256 jobId)
        external
        view
        override
        returns (
            uint256 fee,
            uint256 feePerNum,
            uint256 tokenFee,
            uint256 tokenFeePerNum,
            uint256 numCount,
            uint256 acceptanceTimeLimit,
            address[] memory validators
        )
    {
        JobRequest storage request = _getJobRequest(jobId);
        return (
            request.baseAdaFee,
            request.adaFeePerNum,
            request.baseTokenFee,
            request.tokenFeePerNum,
            request.numCount,
            request.jobAcceptanceExpiration,
            request.validators
        );
    }

    function isJobReady(uint256 jobId) external view override returns (bool) {
        JobRequest storage request = _getJobRequest(jobId);
        return block.timestamp > request.jobAcceptanceExpiration;
    }

    function isResponseSubmitted(uint256 jobId)
        external
        view
        override
        returns (bool)
    {
        JobRequest storage request = _getJobRequest(jobId);
        return request.nodeDataId[msg.sender] != 0;
    }

    function getRewards(uint256 jobId)
        external
        view
        override
        returns (uint256, uint256)
    {
        JobRequest storage request = _getJobRequest(jobId);
        return (request.adaRewards[msg.sender], request.tokenRewards[msg.sender]);
    }

    function getTotalRewards()
        external
        view
        override
        returns (uint256, uint256)
    {
        return (s_validatorRewards[msg.sender].ada, s_validatorRewards[msg.sender].token);
    }

    function _getRandomNumbers(uint256 dataId)
        internal
        view
        returns (uint256[] memory)
    {
        return s_jobRandomNumbers[dataId];
    }

    function _getDataId(uint256 jobId, uint256[] calldata data, uint256 timestamp, address requester) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(jobId, data, timestamp, requester)));
    }

    function _getJobRequest(uint256 jobId) internal view virtual returns (JobRequest storage);
}
