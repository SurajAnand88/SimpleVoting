// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {SimpleVoting} from "./SimpleVoting.sol";
import {IExtendedVoting} from "./IExtendedVoting.sol";
import {console} from "forge-std/Test.sol";

contract ExtendedVoting is SimpleVoting, IExtendedVoting {
    error AlreadyVotedThisRound(address voter);

    event VoteRoundCompleted(uint256 round);
    event DonationSent(address indexed winner, uint256 indexed amount);

    uint256 public voteRound;
    mapping(address => uint256) public lastVotedRound;

    function resetVote() external onlyOwner {
        require(voteRound < 100, "Max VoteRound Reached");
        for (uint256 i = 0; i < candidates.length; i++) {
            candidates[i].voteCount = 0;
        }
        emit VoteRoundCompleted(voteRound);
        roundWinner[latestWinner] = voteRound;
        voteRound++;
    }

    function vote(address _candidateAddr) public payable virtual override {
        if (hasVoted[msg.sender] || lastVotedRound[msg.sender] == voteRound) revert AlreadyVotedThisRound(msg.sender);
        uint256 oldCount = candidates[candidateIndex[_candidateAddr].index].voteCount;
        candidates[candidateIndex[_candidateAddr].index].voteCount++;
        require(candidates[candidateIndex[_candidateAddr].index].voteCount == oldCount + 1, "Count did not Increment");
        hasVoted[msg.sender] = true;
        lastVotedRound[msg.sender] = voteRound;
        emit VotedToCandidate(msg.sender, _candidateAddr);
    }

    function getWinnerName() external onlyOwner returns (string memory) {
        address winner = super.getWinner();
        return candidates[candidateIndex[winner].index].name;
    }

    function donateToLatestWinner() public payable {
        console.log("Donation.........", msg.value);
        payable(latestWinner).transfer(msg.value);
        emit DonationSent(latestWinner, msg.value);
    }

    function getVoteRoundOfVoter(address _voter) public view returns (uint256) {
        return lastVotedRound[_voter];
    }
}
