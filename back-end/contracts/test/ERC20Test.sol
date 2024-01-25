//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Test is ERC20 {
    constructor() ERC20("Test Token", "TST") {
        _mint(msg.sender, 1000000000000000000000000);
    }

    /* Changing the number of decimals to 10 for testing getExpectedPrice function in SingleTokenSwap contract */
    function decimals() public view override returns (uint8) {
        return 10;
    }
}
