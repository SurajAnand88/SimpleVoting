// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {VotingWithEntryFee} from "src/VotingWithEntryFee.sol";

contract DeployVotingWithEntryFee is Script {
    function run() public returns (VotingWithEntryFee) {
        VotingWithEntryFee vwef;
        vm.startBroadcast();
        vwef = new VotingWithEntryFee();
        vm.stopBroadcast();
        return vwef;
    }
}
