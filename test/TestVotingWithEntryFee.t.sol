// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test, console} from "forge-std/Test.sol";
import {VotingWithEntryFee} from "src/VotingWithEntryFee.sol";
import {DeployVotingWithEntryFee} from "script/DeployVotingWithEntryFee.s.sol";

contract TestVotingWithEntryFee is Test {
    VotingWithEntryFee public vwef;
    DeployVotingWithEntryFee public deployer;

    uint256 public defaultAmount = 10 ether;
    uint256 public votingFee = 0.01 ether;
    uint256 public donation = 1 ether;

    address voter1 = makeAddr("Voter1");
    address voter2 = makeAddr("Voter2");
    address candidate1 = makeAddr("candidate1");
    address candidate2 = makeAddr("candidate2");

    string candidateName1 = "First Candidate";
    string candidateName2 = "Second Candidate";
    string ContractType = "Voting";

    function setUp() public {
        deployer = new DeployVotingWithEntryFee();
        vwef = deployer.run();
        vm.deal(voter1, defaultAmount);
        vm.deal(voter2, defaultAmount);
    }

    function testContractType() public view {
        string memory getContractType = vwef.getContractType();
        assertEq(keccak256(bytes(abi.encodePacked(getContractType))), keccak256(bytes(abi.encodePacked(ContractType))));
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

    //Vote Testing
    function testAddVoteShouldIncreaseTheVoteCountAndIncreaseTheContractBalance() public addCandidate {
        (, uint256 preVoteCount,) = vwef.getCandidateInfo(candidate1);
        uint256 preBalace = vwef.checkBalance();

        //Act
        vm.startPrank(voter1);
        vwef.vote{value: votingFee}(candidate1);
        (, uint256 afterVoteCount,) = vwef.getCandidateInfo(candidate1);
        uint256 afterBalance = vwef.checkBalance();
        assertEq(preVoteCount + 1, afterVoteCount);
        assertEq(preBalace + votingFee, afterBalance);
        assertEq(vwef.checkUserHasVoted(), true);
        vm.stopPrank();
    }

    function testAddVoteShouldFailedIfNotSendingEqualVotingFee() public addCandidate {
        vm.startPrank(voter1);
        vm.expectRevert();
        vwef.vote{value: 0}(candidate1);
        vm.expectRevert();
        vwef.vote{value: 1}(candidate1);
        vm.stopPrank();
    }

    function testVoteShouldFailIfSameUserVotingTwice() public addCandidate {
        vm.startPrank(voter1);
        vwef.vote{value: votingFee}(candidate1);
        vm.expectRevert();
        vwef.vote{value: votingFee}(candidate1);
        vm.stopPrank();
    }

    //Test getwinner

    function testGetWinnerShouldRevertIfNoCandidateJoined() public defaultSender {
        vm.expectRevert();
        vwef.getWinner();
    }

    function testGetWinnerShouldAccounceWinner() public addCandidate {
        vm.prank(DEFAULT_SENDER);
        vwef.addCandidate(candidate2, candidateName2);
        vm.prank(voter1);
        vwef.vote{value: votingFee}(candidate1);
        vm.prank(voter2);
        vwef.vote{value: votingFee}(candidate2);
        vm.prank(DEFAULT_SENDER);
        address winner = vwef.getWinner();
        assertEq(winner, candidate1);
    }

    function testGetWinnerShouldRevertIfNoVoteHasGiven() public addCandidate {
        vm.prank(DEFAULT_SENDER);
        vm.expectRevert();
        vwef.getWinner();
    }

    //Reset vote round
    function testResetVoteRoundShouldIncreaseTheVoteRound() public addCandidate {
        uint256 preVoteRound = vwef.voteRound();
        uint256 voterRound = vwef.getVoteRoundOfVoter(voter1);
        vm.prank(voter1);
        vwef.vote{value: votingFee}(candidate1);
        vm.prank(voter2);
        vwef.vote{value: votingFee}(candidate1);
        vm.prank(DEFAULT_SENDER);
        vwef.resetVote();
        uint256 afterVoteRound = vwef.voteRound();
        assertEq(preVoteRound + 1, afterVoteRound);
        assertEq(voterRound, preVoteRound);
    }

    function testGetWinnerName() public addCandidate {
        vm.prank(voter1);
        vwef.vote{value: votingFee}(candidate1);
        vm.prank(DEFAULT_SENDER);
        string memory actualWinner = vwef.getWinnerName();
        assertEq(keccak256(bytes(abi.encodePacked(candidateName1))), keccak256(bytes(abi.encodePacked(actualWinner))));
    }

    function testDonateToWinnerShouldIncreaseTheWinnerBalance() public addCandidate {
        vm.prank(voter1);
        vwef.vote{value: votingFee}(candidate1);
        vm.prank(DEFAULT_SENDER);
        address winner = vwef.getWinner();
        uint256 winnerBalanceBeforeDonation = address(winner).balance;
        console.log(winnerBalanceBeforeDonation);
        vm.prank(voter1);
        vwef.donateToLatestWinner{value: donation}();
        uint256 winnerBalanceAfterDonation = address(winner).balance;
        console.log(winnerBalanceAfterDonation);
        assertEq(winnerBalanceBeforeDonation + donation, winnerBalanceAfterDonation);
    }

    //Fuzz Test
    function testVotingWithFee(uint256 fee) public addCandidate {
        vm.assume(fee <= type(uint256).max && fee >= votingFee && fee != votingFee);
        console.log(fee);
        vm.deal(voter1, fee);
        vm.prank(voter1);
        vm.expectRevert();
        vwef.vote{value: fee}(candidate1);
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
