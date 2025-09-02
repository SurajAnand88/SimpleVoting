// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IExtendedVoting {
    function resetVote() external;
    function getWinnerName() external view returns (string memory);
}
