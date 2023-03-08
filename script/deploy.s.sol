// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/CensorshipOracle.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.createSelectFork(vm.rpcUrl("goerli"));
        vm.broadcast();
        CensorshipOraclePOC poc = new CensorshipOraclePOC();
        vm.broadcast();
        poc.startTest(10, 1_000_000);
    }
}
