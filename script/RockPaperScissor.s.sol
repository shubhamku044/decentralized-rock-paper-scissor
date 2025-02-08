// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RockPaperScissor} from "../src/RockPaperScissor.sol";

contract RockPaperScissorScript is Script {
    RockPaperScissor public rps;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        rps = new RockPaperScissor();

        vm.stopBroadcast();
    }
}
