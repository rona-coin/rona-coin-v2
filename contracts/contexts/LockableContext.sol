// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './OwnableContext.sol';



contract LockableContext is OwnableContext {

    bool private _locked;

    uint256 private _unlockableOnTimestamp;

    constructor() {
        _locked = false;
        _unlockableOnTimestamp = _msgTimestamp();
    }


    event Locked(address lockedContext);
    event Unlocked(address unlockedContext);


    modifier onlyIfUnlocked() {
        require(!_locked(), "Only If Locked");
        _;
    }

    modifier onlyIfLocked() {
        require(_locked(), "Only If Locked: ");
        _;
    }


    function locked() public view returns (bool) {
        return _locked();
    }

    function _locked() internal view returns (bool) {
        return _locked;
    }

    function unlockableOnTimestamp() public pure returns (uint256) {
        return _unlockableOnTimestamp();
    }

    function _unlockableOnTimestamp() internal pure returns (uint256) {
        return _msgTimestamp() < _unlockableOnTimestamp ? _unlockableOnTimestamp : _msgTimestamp();
    }

    function lock() external onlyOwner onlyIfUnlocked {
        _lock();
    }

    function _lock() internal onlyIfUnlocked {
        _locked = true;
        _unlockableOnTimestamp = _msgTimestamp();

        emit Locked(_context());
    }

    function unlock() external onlyOwner onlyIfLocked {
        _unlock();
    }

    function _unlock() internal onlyIfLocked {
        require(_msgTimestamp() >= _unlockableOnTimestamp(), "Unlock: context is not unlockable yet");
        _locked = false;

        emit Unlocked(_context());
    }

    function lockForDurationDays(uint256 lockDurationDays) external onlyOwner onlyIfUnlocked {
        _lockForDurationDays(lockDurationDays);
    }
    
    function _lockForDurationDays(uint256 lockDurationDays) internal onlyIfUnlocked {
        _locked = true;
        _unlockableOnTimestamp = _msgTimestamp() + (lockDuration*86400);

        emit Locked(address(this));
    }

}