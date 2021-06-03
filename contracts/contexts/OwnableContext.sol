// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './CallableContext.sol';

contract OwnableContext is CallableContext {

    address private _owner;


    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }


    modifier onlyOwner() {
        require(_msgSender() == _owner(), "Only Owner: caller is not context owner");
        _;
    }


    event OwnershipTransferred(address previousOwner, address newOwner);


    function owner() external view returns (address) {
        return _owner;
    }

    function _owner() internal view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != _owner, "Transfer Ownership: new owner is already owner");
        require(newOwner != address(0), "Transfer Ownership: new owner cannot be the 0 address");

        address previousOwner = _owner;
        _owner = newOwner;

        emit OwnershipTransferred(previousOwner, _owner);
    }

    function renounceOwnership() external onlyOwner {
        _renounceOwnership();
    }

    function _renounceOwnership() internal {
        address previousOwner = _owner;
        _owner = address(0);

        emit OwnershipTransferred(previousOwner, _owner);
    }

}