// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ICarrier {

    // Carrry tokens
    function carry(address from, address to, uint256 amount) public returns (bool);

}