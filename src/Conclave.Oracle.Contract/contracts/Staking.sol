// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IStakeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking is IStakeable {
    /* STAKING PROPERTIES */
    IERC20 public immutable _token;
    uint256 public s_minStake;
    mapping(address => uint256) public s_stakes;

    error InsufficientBalance(uint256 requested, uint256 balance);

    modifier isValidAmount(uint256 amount) {
        require(amount > 0, "Staking: Amount must be greater than 0");
        _;
    }

    constructor(IERC20 token, uint256 minStake) {
        _token = token;
        s_minStake = minStake;
    }

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
