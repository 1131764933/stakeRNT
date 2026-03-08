// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract esRNT is ERC20, Ownable {
    struct LockInfo {
        address user;
        uint256 amount;
        uint256 lockTime;
    }
    LockInfo[] public locks;
    IERC20 public rntToken;
    event Minted(address indexed _user, uint256 _amount, uint256 lockId);
    constructor(IERC20 _rntToken) ERC20("Escrowed Reward Token", "esRNT") Ownable(msg.sender){
        rntToken = _rntToken;
        _transferOwnership(msg.sender);  
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        locks.push(LockInfo({
            user: to,
            amount: amount,
            lockTime: block.timestamp
        }));
        uint256 lockId = locks.length - 1;

        emit Minted( to, amount, lockId);
    }

    function burn(uint256 lockId) public {
        require(lockId<locks.length, "Invalid lockId");
        LockInfo storage lock = locks[lockId];
        require(lock.user == msg.sender, "Not the owner of the lock");

        uint256 unlocked = (lock.amount*(block.timestamp - lock.lockTime))/30 days;

        uint256 burnAmount= lock.amount-unlocked;

        _burn(msg.sender, lock.amount);
        rntToken.transfer(msg.sender, unlocked);
        rntToken.transfer(address(0), burnAmount);
    }
    function getLocksByUser(address user) external view returns (LockInfo[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < locks.length; i++) {
            if (locks[i].user == user) {
                count++;
            }
        }

        LockInfo[] memory userLocks = new LockInfo[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < locks.length; i++) {
            if (locks[i].user == user) {
                userLocks[index] = locks[i];
                index++;
            }
        }
        return userLocks;
    }
}