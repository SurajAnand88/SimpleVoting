    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IVoting {
    function addCandidate(address _candidate, string memory _name) external;
    function getWinner() external view returns (address);
}
