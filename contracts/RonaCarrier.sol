// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './contexts/BuildableContext.sol';
import './interfaces/IBEP20.sol';
import './interfaces/ICarrier.sol';
import './libraries/SafeMath.sol';


contract RonaCarrier is BuildableContext, ICarrier {

    using SafeMath for uint256;

    address private _wBNB;

    address private _ronaCoinV1;
    address private _ronaCoinV2;

    uint256 private _charityFeePercentage;
    uint256 private _holderDistributionFeePercentage;
    uint256 private _liquidityPoolingFeePercentage;

    address private _charityWalletAddress;

    mapping (address => uint256) private _owedRonaDistributions;
    address[] private _ronaHolders;


    constructor (uint256 charityFeePercentage, uint256 holderDistributionFeePercentage, uint256 liquidityPoolingFeePercentage) {
        require((charityFeePercentage + holderDistributionFeePercentage + liquidityPoolingFeePercentage) < 100, "Transfer fees: transfer fees cannot total more than 100%");

        _wBNB = address(0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c);

        _ronaCoinV1 = address(0x864397B060A2210E9DeD2e9a8D63CD7A83eb0EF0);
        _ronaCoinV2 = address(0);

        _charityFeePercentage = charityFeePercentage;
        _holderDistributionFeePercentage = holderDistributionFeePercentage;
        _liquidityPoolingFeePercentage = liquidityPoolingFeePercentage;

        _charityWalletAddress = address(0);
    }


    function carry(address token, uint256 amount) public returns (bool) {
        require(_msgSender() == _ronaCoinV2, "Carry: cannot carry tokens from sender's address");
        require(token == _ronaCoinV2, "Carry: cannot carry token type");
        require(IBEP20(token).balanceOf(address(this)) >= amount, "Carry: insufficent carrier balance");

        // carry charity fee
        _owedRonaDistributions[_charityWalletAddress] = _owedRonaDistributions[_charityWalletAddress].add(amount.mul(_charityFeePercentage).div(_totalTransferFeePercentage()));

        // carry holder distribution fee
        // TODO - Implement this, whats the best way? blocked distributions, RFI??
        // ...

        // carry liquidity pooling fee
        // TODO - Implement this
        // ...

        return true;
    }


    function ronaCoinV1() external view returns (address) {
        return _ronaCoinV1;
    }
    
    function ronaCoinV2() external view returns (address) {
        return _ronaCoinV2;
    }
    
    function charityFeePercentage() external view returns (uint256) {
        return _charityFeePercentage;
    }

    function holderDistributionFeePercentage() external view returns (uint256) {
        return _holderDistributionFeePercentage;
    }

    function liquidityPoolingFeePercentage() external view returns (uint256) {
        return _liquidityPoolingFeePercentage;
    }

    function totalTransferFeePercentage() external view returns (uint256) {
       return _totalTransferFeePercentage(); 
    }

    function _totalTransferFeePercentage() internal view returns (uint256) {
        return (_charityFeePercentage + _holderDistributionFeePercentage + _liquidityPoolingFeePercentage);
    }

    function ronaCharityWalletAddress() external view returns (address) {
        return _charityWalletAddress;
    }

    function setRonaCoinV2Address(address ronaCoinV2Address) external onlyFactory returns(bool) {
        require(_ronaCoinV2 == address(0), "Set Rona Coin V2 address: V2 address already set");
        require(ronaCoinV2Address != address(0), "Set Rona Coin V2 address: cannot set to 0 address");
        
        _ronaCoinV2 = ronaCoinV2Address;

        return true;
    }

    function updateCharityFeePercentage(uint256 newCharityFeePercentage) external onlyFactory returns (bool) {
        require((newCharityFeePercentage + _holderDistributionFeePercentage + _liquidityPoolingFeePercentage) < 100, "Update fee: total fees cannot exceed 100");

        _charityFeePercentage = newCharityFeePercentage;

        return true;
    }

    function updateHolderDistributionFeePercentage(uint256 newHolderDistributionFeePercentage) external onlyFactory returns (bool) {
        require((_charityFeePercentage + newHolderDistributionFeePercentage + _liquidityPoolingFeePercentage) < 100, "Update fee: total fees cannot exceed 100");

        _holderDistributionFeePercentage = newHolderDistributionFeePercentage;

        return true;
    }

    function updateLiquidityPoolingFeePercentage(uint256 newLiquidityPoolingFeePercentage) external onlyFactory returns (bool) {
        require((_charityFeePercentage + _holderDistributionFeePercentage + newLiquidityPoolingFeePercentage) < 100, "Update fee: total fees cannot exceed 100");

        _liquidityPoolingFeePercentage = newLiquidityPoolingFeePercentage;

        return true;
    }

    function updateCharityWalletAddress(address newCharityWalletAddress) external onlyFactory returns (bool) {
        require(newCharityWalletAddress != address(0), "Update charity wallet address: charity wallet address cannot be the 0 address");

        if(_charityWalletAddress == address(0)){
            _owedRonaDistributions[newCharityWalletAddress] = _owedRonaDistributions[newCharityWalletAddress].add(_owedRonaDistributions[address(0)]);
            _owedRonaDistributions[address(0)] = 0;
        }

        _charityWalletAddress = newCharityWalletAddress;

        return true;
    }
}