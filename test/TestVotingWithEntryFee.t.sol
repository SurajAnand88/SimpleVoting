// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test, console} from "forge-std/Test.sol";
import {VotingWithEntryFee} from "src/VotingWithEntryFee.sol";
import {DeployVotingWithEntryFee} from "script/DeployVotingWithEntryFee.s.sol";

contract TestVotingWithEntryFee is Test {
    VotingWithEntryFee public vwef;
    DeployVotingWithEntryFee public deployer;

    uint256 public defaultAmount = 10 ether;

    address voter1 = makeAddr("Voter1");
    address voter2 = makeAddr("Voter2");

    function setUp() public {
        deployer = new DeployVotingWithEntryFee();
        vwef = deployer.run();
        vm.deal(voter1, defaultAmount);
        vm.deal(voter2, defaultAmount);
    }

    function test
}
