// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/StakePool.sol";
import "../src/RNT.sol";
import "../src/esRNT.sol";

contract DeployStakePool is Script {
    function run() external {
        address rntAddress = vm.envAddress("RNT_ADDRESS");
        address esrntAddress = vm.envAddress("ESRNT_ADDRESS");

        vm.startBroadcast();

        StakePool stakePool = new StakePool(IERC20(rntAddress), esRNT(esrntAddress));

        vm.stopBroadcast();

        console.log("StakePool deployed at:", address(stakePool));
    }
}
