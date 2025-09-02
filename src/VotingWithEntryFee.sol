// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ExtendedVoting} from "./ExtendedVoting.sol";

contract VotingWithEntryFee is ExtendedVoting {
    uint256 public votingFee = 0.01 ether;
    uint256 public VoteFeeCollection;

    error InsufficientFee(uint256 required, uint256 sent);

    function vote(address _candidateAddr) public payable override {
        require(!hasVoted[msg.sender] || lastVotedRound[msg.sender] < voteRound, "Already Voted");
        if (msg.value < votingFee) revert InsufficientFee(votingFee, msg.value);

        candidates[candidateIndex[_candidateAddr].index].voteCount++;
        hasVoted[msg.sender] = true;
        lastVotedRound[msg.sender] = voteRound;
        emit VotedToCandidate(msg.sender, _candidateAddr);
        VoteFeeCollection += msg.value;
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
