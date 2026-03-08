// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StakePool.sol";
import "../src/RNT.sol";
import "../src/esRNT.sol";

contract StakePoolTest is Test {
    RNT rntToken;
    esRNT esrntToken;
    StakePool stakePool;
    address owner;
    address user1;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);

        // 部署 RNT 和 esRNT 合约
        rntToken = new RNT();
        esrntToken = new esRNT(IERC20(address(rntToken)));

        // 部署 StakePool 合约
        stakePool = new StakePool(IERC20(address(rntToken)), esrntToken);

        // 将一些 RNT 分配给用户
        rntToken.transfer(user1, 1000 ether);
    }

    function testStake() public {
        vm.startPrank(user1);

        // 用户授权 StakePool 合约可以花费 RNT
        rntToken.approve(address(stakePool), 1000 ether);

        // 用户质押 100 RNT
        stakePool.stake(100 ether);

        // 检查质押结果
        (uint256 staked,,) = stakePool.stakes(user1);
        assertEq(staked, 100 ether);
        assertEq(rntToken.balanceOf(user1), 900 ether);

        vm.stopPrank();
    }

    function testUnstake() public {
        vm.startPrank(user1);

        // 用户授权 StakePool 合约可以花费 RNT
        rntToken.approve(address(stakePool), 1000 ether);

        // 用户质押 100 RNT
        stakePool.stake(100 ether);

        // 用户取消质押 50 RNT
        stakePool.unstake(50 ether);

        // 检查取消质押结果
        (uint256 staked,,) = stakePool.stakes(user1);
        assertEq(staked, 50 ether);
        assertEq(rntToken.balanceOf(user1), 950 ether);

        vm.stopPrank();
    }

    // function testClaim() public {
    //     vm.startPrank(user1);

    //     // 用户授权 StakePool 合约可以花费 RNT
    //     rntToken.approve(address(stakePool), 1000 ether);

    //     // 用户质押 100 RNT
    //     stakePool.stake(100 ether);

    //     // 快进时间30天，获取奖励
    //     vm.warp(block.timestamp + 30 days);

    //     // 用户领取奖励
    //     stakePool.claim();

    //     // 检查领取结果
    //     assertEq(esrntToken.balanceOf(user1), 100 ether);

    //     vm.stopPrank();
    // }
}
