// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {SimpleVoting} from "./SimpleVoting.sol";
import {IExtendedVoting} from "./IExtendedVoting.sol";

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

    function getWinnerName() external view onlyOwner returns (string memory) {
        address winner = super.getWinner();
        return candidates[candidateIndex[winner].index].name;
    }

    function donateToWinner() public payable {
        address winner = getPublicWinner();
        payable(winner).transfer(msg.value);
        emit DonationSent(winner, msg.value);
    }
}
