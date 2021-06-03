// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './OwnableContext.sol';

contract DestructableContext is OwnableContext {

    event Destroyed(address destroyedContext);


    function destroy() external onlyOwner {
        _destroy();
    }

    function _destroy() internal virtual {
        _renounceOwnership();
        selfdestruct(_owner());
        emit Destroyed(_context());
    }

}