// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Ownable} from "./Ownable.sol";
import {IVoting} from "./IVoting.sol";
import {SafeVoteMath} from "./SafeVoteMath.sol";
import {console} from "forge-std/Test.sol";

contract SimpleVoting is Ownable, IVoting {
    using SafeVoteMath for uint256;

    event CandidateAdded(string indexed name);
    event VotedToCandidate(address indexed voter, address indexed candidate);
    event Winner(address indexed winner, string name);

    constructor() {}

    struct Candidate {
        string name;
        uint256 voteCount;
        address addr;
    }

    struct CandidateIndexAndAvailbility {
        uint256 index;
        bool isAvailable;
    }

    address public latestWinner;
    Candidate[] public candidates;
    mapping(address => CandidateIndexAndAvailbility) public candidateIndex;
    mapping(address => bool) public hasVoted;
    mapping(address => uint256) public roundWinner;

    function addCandidate(address _addr, string memory _name) public onlyOwner {
        require(bytes(_name).length > 0, "Invalid Name");
        require(_addr != address(0));
        require(!candidateIndex[_addr].isAvailable, "Already Registered");
        candidates.push(Candidate(_name, 0, _addr));
        emit CandidateAdded(_name);
        candidateIndex[_addr] = CandidateIndexAndAvailbility(candidates.length - 1, true);
    }

    function vote(address _candidateAddr) public payable virtual {
        require(!hasVoted[msg.sender], "Already voted");
        candidates[candidateIndex[_candidateAddr].index].voteCount.safeIncrement();
        hasVoted[msg.sender] = true;
        emit VotedToCandidate(msg.sender, _candidateAddr);
    }

    function getWinner() public onlyOwner returns (address winner) {
        require(candidates.length > 0, "Not Enough Candidates to Count the Vote");
        uint256 maxVote = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVote) {
                maxVote = candidates[i].voteCount;
                winner = candidates[i].addr;
            }
        }
        assert(maxVote > 0);
        latestWinner = winner;
        return winner;
    }

    function getContractType() public pure override returns (string memory) {
        return "Voting";
    }

    function announceWinner() public onlyOwner {
        address winner = getWinner();
        emit Winner(winner, candidates[candidateIndex[winner].index].name);
    }

    function getCandidateInfo(address _candidate)
        public
        view
        returns (string memory name, uint256 voteCount, address addr)
    {
        Candidate memory candidate = candidates[candidateIndex[_candidate].index];
        return (candidate.name, candidate.voteCount, candidate.addr);
    }
}
