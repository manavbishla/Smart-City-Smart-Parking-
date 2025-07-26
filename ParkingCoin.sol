// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";

contract ParkingCoin is ERC20 {
    
    constructor(address initialOwner) ERC20("ParkingCoin", "PKC") {
        _mint(initialOwner, 1000000 * 10**decimals());
    }
}