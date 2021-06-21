// Rona Coin Version 2
// CallableContext.sol
// Developed by Stew, May-June 2021

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract CallableContext {

    function _context() internal view returns (address) {
        return address(this);
    }
    

    function _msgSender() internal view returns (address) {
        return address(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }

    function _msgTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

}