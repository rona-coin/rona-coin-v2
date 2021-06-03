// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './OwnableContext.sol';

contract ManageableContext is OwnableContext {

    address[] private _managers;
    mapping (address => uint256) private _managersMap;


    constructor() {
        _managers = new address[];
        _managers.push(initialOwner);
        _managersMap[initialOwner] = 1;
    }


    event ManagerAdded(address newManager);
    event ManagerRemoved(address removedManager);


    modifier onlyManager() {
        require(_managersMap[_msgSender()] != 0 , "Only Manager: caller is not a context manager");
        _;
    }

    function managers() public view returns (address[]) {
        return _managers();
    }

    function _managers() internal view returns (address[]) {
        return _managers;
    }

    function addManager(address newManager) external onlyOwner {
        _addManager(newManager);
    }

    function _addManager(address newManager) internal {
        require(_managersMap[newManager] == 0, "Add Manager: new manager is already a manager");

        _managers.push(newManager);
        _managersMap[newManager] = _managers.length;

        emit ManagerAdded(newManager);
    }

    function removeManager(address managerToRemove) external onlyOwner {
        _removeManager(managerToRemove);
    }

    function _removeManager(address managerToRemove) internal {
        require(_managersMap[newManager] != 0, "Remove Manager: manager to remove is already not a manager");
        require(managerToRemove != _owner(), "Remove Manager: cannot remove owner from managers list");

        delete _managers[_managersMap[managerToRemove] - 1];
        for(uint256 i = _managersMap[managerToRemove] - 1; i < _managers.length; i++) {
           _managersMap[_managers[i]] = i+1; 
        }
        _managersMap[managerToRemove] = 0;

        emit ManagerRemoved(managerToRemove);
    }

}