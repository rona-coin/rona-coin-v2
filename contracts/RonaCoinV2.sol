// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './contexts/BuildableContext.sol';
import './interfaces/IBEP20.sol';
import './interfaces/ICarrier.sol';
import './libraries/SafeMath.sol';

contract RonaCoinV2 is BuildableContext, IBEP20 {

    using SafeMath for uint256;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private _decimals;

    address private _carrier;


    constructor (string name, string symbol, uint256 initialSupply, uint8 decimals, address carrier) {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = initialSupply * (10**_decimals);

        _carrier = carrier;

        _balances[_carrier] = _totalSupply;
        emit Transfer(address(0), _carrier, _totalSupply);
    }


    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }
    
    function getOwner() external view returns (address) {
        return _factory();
    }

    function carrier() external view returns (address) {
        return _carrier;
    }
    
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipiant, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipiant, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
    }

    function transferFrom(address sender, address recipiant, uint256 amount) external returns (bool) {
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(allowanceDecrease, "Transfer from: cannot transfer more than allowance"));
        _transfer(sender, recipiant, amount);
        return true;
    }

    function increaseAllowance(address spender uint256 allowanceIncrease) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(allowanceIncrease));
        return true;
    }

    function decreaseAllowance(address spender, uint256 allowanceDecrease) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(allowanceDecrease, "Decrease allowance: cannot decrease allowance below zero"));
        return true;
    }

    function mint(uint256 amount) external onlyFactory returns (bool) {
        _mint(_carrier, amount);
        return true;
    }

    function burn(uint256 amount) external onlyFactory returns (bool) {
        _burn(_carrier, amount);
        return true;
    }

    function updateCarrier(address newCarrier) external onlyFactory returns (bool) {
        _carrier = newCarrier;

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Transfer: cannot transfer from the 0 address");
        require(to != address(0), "Transfer: cannot transfer to the 0 address");

        _balances[from] = _balances[from].sub(amount, "Transfer: amount exceeds senser's balance");

        if(from == _carrier || _carrier == address(0)) {
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from, to, amount);
        } else {
            _balances[_carrier] = _balances[_carrier].add(amount);
            emit Transfer(from, _carrier, amount);

            ICarrier(_carrier).carry(from, to, amount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve: cannot approve transfer from 0 address.");
        require(spender != address(0), "Approve: cannot approve transfer to 0 address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
    
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Mint: cannot mint to the 0 address");

        amount = amount * (10**_decimals);

        _balances[to] = _balances[to].add(amount);
        _totalSupply = _totalSupply.add(amount);

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "Burn: cannot burn from the 0 address");

        amount = amount * (10**_decimals);

        _balances[from] = _balances[from].sub(amount, "Burn: amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(from, address(0), amount);
    }

}