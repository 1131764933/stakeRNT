// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/esRNT.sol";
import "../src/RNT.sol";  

contract DeployEsRNT is Script {
    function run() external {

        address rntAddress=vm.envAddress("RNT_ADDRESS");

        vm.startBroadcast();
        esRNT esrnt = new esRNT(IERC20(rntAddress));
        vm.stopBroadcast();
        console.log("esRNT deployed at:", address(esrnt));
    }
}