// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SafeVoteMath {
    function safeIncrement(uint256 a) internal pure returns (uint256) {
        unchecked {
            uint256 b = a + 1;
            require(b > a, "Overflow");
            return b;
        }
    }
}
