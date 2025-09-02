// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    function getContractType() public pure virtual returns (string memory);

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}
