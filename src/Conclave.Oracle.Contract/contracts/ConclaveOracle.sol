// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./abstracts/ConclaveOracleOperator.sol";
import "./interfaces/IConclaveOracle.sol";

contract ConclaveOracle is IConclaveOracle, ConclaveOracleOperator {
    uint32 s_minNumCount = 1;
    uint32 s_maxNumCount = 500;
    uint256 s_jobAcceptanceTimeLimitInSeconds;
    uint256 s_jobFulfillmentLimitPerNumberInSeconds;

    uint256 nonce;

    error ValueMismatch(uint256 stated, uint256 actual);
    error NumberCountNotInRange(uint256 min, uint256 max, uint256 actual);

    event JobRequestCreated(uint256 jobId, uint32 indexed numCount);

    mapping(uint256 => JobRequest) /* jobId => jobRequest */
        private s_jobRequests;

    constructor(
        IERC20 token,
        uint256 minValidatorStake,
        uint256 jobAcceptanceTimeLimitInSeconds,
        uint256 jobFulfillmentLimitPerNumberInSeconds,
        uint24 minValidator,
        uint24 maxValidator
    )
        ConclaveOracleOperator(
            token,
            minValidatorStake,
            minValidator,
            maxValidator
        )
    {
        s_jobAcceptanceTimeLimitInSeconds = jobAcceptanceTimeLimitInSeconds;
        s_jobFulfillmentLimitPerNumberInSeconds = jobFulfillmentLimitPerNumberInSeconds;
    }

    receive() external payable {}

    function requestRandomNumbers(
        uint24 numCount,
        uint256 fee,
        uint256 feePerNum,
        uint256 tokenFee,
        uint256 tokenFeePerNum
    ) external payable returns (uint256 jobId) {
        uint256 totalFee = fee + (numCount * feePerNum);
        uint256 totalTokenFee = tokenFee + (numCount * tokenFeePerNum);

        if (msg.value != totalFee) {
            revert ValueMismatch(msg.value, totalFee);
        }

        if (numCount < s_minNumCount || numCount > s_maxNumCount) {
            revert NumberCountNotInRange(
                s_minNumCount,
                s_maxNumCount,
                numCount
            );
        }

        _token.transferFrom(msg.sender, address(this), totalTokenFee);
        jobId = _getJobId(msg.sender, numCount, block.timestamp, nonce);

        uint256 jobAcceptanceTimeLimit = block.timestamp +
            s_jobAcceptanceTimeLimitInSeconds;

        uint256 jobFulfillmentLimit = block.timestamp +
            jobAcceptanceTimeLimit +
            (s_jobFulfillmentLimitPerNumberInSeconds * numCount);

        JobRequest storage jobRequest = s_jobRequests[jobId];
        jobRequest.jobId = jobId;
        jobRequest.baseAdaFee = fee;
        jobRequest.adaFeePerNum = feePerNum;
        jobRequest.baseTokenFee = tokenFee;
        jobRequest.tokenFeePerNum = tokenFeePerNum;
        jobRequest.timestamp = block.timestamp;
        jobRequest.jobAcceptanceExpiration = jobAcceptanceTimeLimit;
        jobRequest.jobFulfillmentExpiration = jobFulfillmentLimit;
        jobRequest.requester = msg.sender;
        jobRequest.numCount = numCount;

        nonce++;

        emit JobRequestCreated(jobId, numCount);
    }

    function aggregateResult(uint256 jobId)
        external
        override
        returns (uint256)
    {}

    function _fulfillRandomNumbers(uint256 jobId) internal {}

    function _calculateOracleFees() internal {}

    function _distributeRewards(uint256 jobId) internal {}

    function _getJobId(
        address requester,
        uint256 numCount,
        uint256 timestamp,
        uint256 _nonce
    ) internal pure returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(requester, numCount, timestamp, _nonce)
                )
            );
    }

    function _getJobRequest(uint256 jobId)
        internal
        view
        virtual
        override
        returns (JobRequest storage)
    {
        return s_jobRequests[jobId];
    }
}
