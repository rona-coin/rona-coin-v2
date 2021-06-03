// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ICarrier {

    function carry(address token, uint256 amount) external returns (bool);

}