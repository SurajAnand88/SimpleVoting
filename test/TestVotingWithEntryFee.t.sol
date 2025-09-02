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
    address candidate1 = makeAddr("candidate1");
    address candidate2 = makeAddr("candidate2");

    string candidateName1 = "First Candidate";
    string candidateName2 = "Second Candidate";

    function setUp() public {
        deployer = new DeployVotingWithEntryFee();
        vwef = deployer.run();
        vm.deal(voter1, defaultAmount);
        vm.deal(voter2, defaultAmount);
    }

    function testAddCandidateShouldAddTheCandidate() public {
        //Act
        vm.prank(DEFAULT_SENDER);
        vwef.addCandidate(candidate1, candidateName1);

        // Assert
        (string memory name, uint256 voteCount, address addr) = vwef.getCandidateInfo(candidate1);
        assertEq(addr, candidate1);
        assertEq(keccak256(bytes(abi.encodePacked(candidateName1))), keccak256(bytes(abi.encodePacked(name))));
        assertEq(voteCount, 0);
    }

    function testAddCandidateShouldFailIfEmptyStringAndAddressGiven() public defaultSender {
        vm.expectRevert();
        vwef.addCandidate(candidate1, "");
        vm.expectRevert();
        vwef.addCandidate(address(0), candidateName1);
    }

    function testAddCandidateShouldFailIfCandidateAlreadyRegistered() public defaultSender {
        vwef.addCandidate(candidate1, candidateName1);
        vm.expectRevert();
        vwef.addCandidate(candidate1, candidateName1);
    }

    modifier addCandidate() {
        vm.prank(DEFAULT_SENDER);
        vwef.addCandidate(candidate1, candidateName1);
        _;
    }

    modifier defaultSender() {
        vm.startPrank(DEFAULT_SENDER);
        _;
        vm.stopPrank();
    }
}
