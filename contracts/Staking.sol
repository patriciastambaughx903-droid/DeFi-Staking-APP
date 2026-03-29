








// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastStakeTime;

    uint256 public rewardRate = 100; // 100 tokens per day per 1000 staked (adjust as needed)

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedAmount[msg.sender] += amount;
        lastStakeTime[msg.sender] = block.timestamp;
    }

    function unstake(uint256 amount) external {
        require(amount <= stakedAmount[msg.sender], "Not enough staked");
        stakedAmount[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    function claimRewards() external {
        uint256 rewards = calculateRewards(msg.sender);
        require(rewards > 0, "No rewards");
        lastStakeTime[msg.sender] = block.timestamp;
        rewardToken.transfer(msg.sender, rewards);
    }

    function calculateRewards(address user) public view returns (uint256) {
        uint256 timeStaked = block.timestamp - lastStakeTime[user];
        return (stakedAmount[user] * rewardRate * timeStaked) / (86400 * 1000); // daily rate
    }
}
