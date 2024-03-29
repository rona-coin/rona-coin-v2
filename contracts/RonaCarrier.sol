// Rona Coin Version 2
// RonaCarrier.sol
// Developed by Stew, May-June 2021

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
    address[] private _ronaDistributionRecievers;
    mapping (address => uint256) private _ronaDistributionRecieversMap;

    uint256 private _pendingRonaHolderDistributions;


    constructor (uint256 charityFeePercentage, uint256 holderDistributionFeePercentage, uint256 liquidityPoolingFeePercentage) {
        require((charityFeePercentage + holderDistributionFeePercentage + liquidityPoolingFeePercentage) < 100, "Transfer fees: transfer fees cannot total more than 100%");

        _wBNB = address(0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c); // hardcoded token address

        _ronaCoinV1 = address(0x864397B060A2210E9DeD2e9a8D63CD7A83eb0EF0); // hardcoded token address
        _ronaCoinV2 = address(0); // setRonaCoinV2Address method must be called once and only once by lab contract after construction of carrier and coin

        _charityFeePercentage = charityFeePercentage;
        _holderDistributionFeePercentage = holderDistributionFeePercentage;
        _liquidityPoolingFeePercentage = liquidityPoolingFeePercentage;

        _charityWalletAddress = address(0);

        _ronaDistributionRecievers = [];

        _pendingRonaHolderDistributions = 0;
    }


    // Carry Rona V2 tokens
    function carry(address from, address to, uint256 amount) public returns (bool) {
        require(_msgSender() == _ronaCoinV2, "Carry: cannot carry tokens from sender's address");
        require(IBEP20(_ronaCoinV2).balanceOf(address(this)) >= amount, "Carry: insufficent carrier balance");

        // ensure holders recieve distributions 
        if(_ronaDistributionRecieversMap[from] == 0){
            _ronaDistributionRecievers.push(from);
            _ronaDistributionRecieversMap[from] = _ronaDistributionRecievers.length;
        }
        if(_ronaDistributionRecieversMap[to] == 0) {
            _ronaDistributionRecievers.push(to);
            _ronaDistributionRecieversMap[to] = _ronaDistributionRecieversMap.length;
        }
        // carry charity fee
        _owedRonaDistributions[_charityWalletAddress] = _owedRonaDistributions[_charityWalletAddress].add(amount.mul(_charityFeePercentage).div(100));
        
        // carry holder distribution fee
        uint256 individualHolderDistribution = amount.mul(_holderDistributionFeePercentage).div(100).add(_pendingRonaHolderDistributions).div(_ronaDistributionRecievers.length);
        if(individualHolderDistribution > 0){
            _pendingRonaHolderDistributions = 0;
            for(uint256 i = 0; i < _ronaDistributionRecievers.length; i++) {
                _owedRonaDistributions[_ronaDistributionRecievers[i]] = _owedRonaDistributions[_ronaDistributionRecievers[i]].add(individualHolderDistribution);

                uint256 k = i;
                while(k >= 1 && _owedRonaDistributions[_ronaDistributionRecievers[k]] > _owedRonaDistributions[_ronaDistributionRecievers[k-1]]){
                    address t = _ronaDistributionRecievers[k-1];
                    _ronaDistributionRecievers[k-1] = _ronaDistributionRecievers[k];
                    _ronaDistributionRecieversMap[_ronaDistributionRecievers[k-1]] = k;
                    _ronaDistributionRecievers[k] = t;
                    _ronaDistributionRecieversMap[t] = k+1;
                    
                    k--;
                }
            }
        } else {
            _pendingRonaHolderDistributions = _pendingRonaHolderDistributions.add(amount.mul(_holderDistributionFeePercentage).div(100));
        }
        


        // carry liquidity pooling fee
        // TODO implement ...



        // carry token transfer
        IBEP20(_ronaCoinV2).transfer(to, amount.sub(amount.mul(_totalTransferFeePercentage()).div(100)));

        // purge non-holders from distributions list or forcefuly retrieve from address' owed distributions
        if(_owedRonaDistributions[from] == 0) {
            if(IBEP20(_ronaCoinV2).balanceOf(from) == 0){
                delete _ronaDistributionRecievers[_ronaDistributionRecieversMap[from]-1];
                for(uint256 i = _ronaDistributionRecieversMap[from]-1; i < _ronaDistributionRecievers.length; i++) {
                    _ronaDistributionRecieversMap[_ronaDistributionRecievers[i]] = i+1;
                }
                _ronaDistributionRecieversMap[from] = 0;
            }
        } else {
            _retrieve(from);
        }
        
        // forcefully retrieve to address' owed distributions
        if(_owedRonaDistributions[to] > 0){
            _retrieve(to);
        }

        // run blocked transfer
        _block();

        return true;
    }

    // Forcefully retrieve sender's owed Rona V2 tokens 
    function retrieve() public returns (bool) {
        return _retrieve(_msgSender());
    }

    function _retrieve(address claimer) internal returns (bool) {
        require(IBEP20(_ronaCoinV2).balanceOf(address(this)) >= _owedRonaDistributions[claimer], "Retrieve: insufficent carrier balance");

        IBEP20(_ronaCoinV2).transfer(claimer, _owedRonaDistributions[claimer]);

        _owedRonaDistributions[claimer] = 0;

        return true;
    }

    // Run block transfer of owed distributuions
    function block() public returns (bool){
        return _block();
    }

    function _block() internal returns (bool) {
        // TODO this is a bad and basic implementation... a more better approach to blocking should be added
        for(uint256 i = 0; i < 100 && i < _ronaDistributionRecievers.length; i++) {
            _retrieve(_ronaDistributionRecievers[i]);
        }
    }

    function swapRonaV1forRonaV2() public returns (bool) {
        return _swapRonaV1forRonaV2(_msgSender());
    }

    function _swapRonaV1forRonaV2(address swapper) internal returns (bool) {
        
        _owedRonaDistributions[swapper] = _owedRonaDistributions[swapper].add(IBEP20(_ronaCoinV1).balanceOf(swapper));

        if(IBEP20(_ronaCoinV1).transferFrom(swapper, address(this), IBEP20(_ronaCoinV1).balanceOf(swapper))) {
            return _retrieve(swapper);
        } else {
            _owedRonaDistributions[swapper] = _owedRonaDistributions[swapper].sub(IBEP20(_ronaCoinV1).balanceOf(swapper));
            return false;
        }

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
        require(_ronaCoinV2 == address(0), "Set Rona Coin V2 address: Rona V2 address already set");
        require(ronaCoinV2Address != address(0), "Set Rona Coin V2 address: cannot set Rona V2 to 0 address");
        
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

        if(_ronaDistributionRecieversMap[newCharityWalletAddress] == 0){
            _ronaDistributionRecievers.push(newCharityWalletAddress);
            _ronaDistributionRecieversMap[newCharityWalletAddress] = _ronaDistributionRecievers.length;
        }

        if(_charityWalletAddress == address(0)){
            _owedRonaDistributions[newCharityWalletAddress] = _owedRonaDistributions[newCharityWalletAddress].add(_owedRonaDistributions[address(0)]);
            _owedRonaDistributions[address(0)] = 0;
        }

        _charityWalletAddress = newCharityWalletAddress;
        
        return true;
    }
}