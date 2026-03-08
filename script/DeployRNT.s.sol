// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/RNT.sol";

contract DeployRNT is Script {

    function setUp() public  {}

    function run() public {
        vm.startBroadcast();
        RNT newRNT = new RNT();
        console.log("RNT deployed to: %s", address(newRNT));
        vm.stopBroadcast();
    }
}

