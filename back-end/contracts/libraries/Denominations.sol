// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/** @dev These denominations are used to get current asset price from chainlink's feed registry 
    In my contract I'm using the USD address for available ERC-20 token price in USD.
*/

library Denominations {
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant BTC = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;

    // Fiat currencies follow https://en.wikipedia.org/wiki/ISO_4217
    address public constant USD = address(840);
    address public constant GBP = address(826);
    address public constant EUR = address(978);

    // Add other Fiat currencies as needed...
}
