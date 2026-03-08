// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RNT.sol";
import "./esRNT.sol";

contract StakePool is Ownable {
    IERC20 public rntToken;
    esRNT public esrntToken;
    mapping(address => StakeInfo) public stakes;
    uint256 public rewardRate=1 ether;

    struct StakeInfo {
        uint256 staked;
        uint256 unclaimed;
        uint256 lastUpdateTime;
    }

    constructor(IERC20 _rntToken,esRNT _esrntToken) Ownable(msg.sender) {
        rntToken = _rntToken;
        esrntToken=_esrntToken;
    }


    function stake(uint256 amount) external {
        updateReward(msg.sender);
        require(amount > 0, "Amount must be greater than 0");
        rntToken.transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender].staked += amount;
    }

    function unstake(uint256 amount) external {
        updateReward(msg.sender);
        require(amount > 0, "Amount must be greater than 0");
        require(stakes[msg.sender].staked >= amount, "Insufficient balance");
        stakes[msg.sender].staked -= amount;
        rntToken.transfer(msg.sender, amount);
    }

    function claim() external {
        updateReward(msg.sender);
        uint256 reward = stakes[msg.sender].unclaimed;
        stakes[msg.sender].unclaimed = 0;
        esrntToken.transfer(msg.sender, reward);
    }


    function updateReward(address account) internal {

        StakeInfo storage stakeInfo = stakes[account];
        if (stakeInfo.lastUpdateTime > 0) {
            uint256 timeStaked = block.timestamp - stakeInfo.lastUpdateTime;
            stakeInfo.unclaimed += (timeStaked * stakeInfo.staked * rewardRate) / 1 days;
        }
        stakeInfo.lastUpdateTime = block.timestamp;
    }
}