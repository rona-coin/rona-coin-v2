// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './CallableContext.sol';

contract BuildableContext is CallableContext {

    address private _factory;


    constructor() {
        _factory = _msgSender();
    }


    modifier onlyFactory() {
        require(_msgSender() == _factory(), "Only Factory: caller is not context factory");
        _;
    }


    function factory() external view returns (address){
        return _factory;
    }

    function _factory internal view returns (address) {
        return _factory;
    }

}