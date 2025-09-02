// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library RoundUtils {
    function isRoundActive(uint256 current, uint256 last) internal pure returns (bool) {
        return (last < current);
    }
}
