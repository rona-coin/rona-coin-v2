// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './contexts/OwnableContext.sol';
import './RonaCarrier.sol';
import './RonaCoinV2.sol';

contract RonaLab is OwnableContext {

    RonaCarrier private _carrier;
    RonaCoinV2 private _coin;


    constructor () {
        _carrier = new RonaCarrier(4, 3, 3); // Initial fees: 4% charity, 3% holders, 3% liduidity pooling
        _coin = new RonaCoinV2('Rona Coin V2', '$RONAv2', 100000000000000, 9, _carrier.ronaTotalTransferFeePercentage(), address(_carrier)); // Initial token supply: 100,000,000,000,000; Token decimals: 9
        _carrier.setRonaCoinV2Address(address(_coin));

        //TODO Build Pancake Swap Pool and link with rona carrier
    }

    function ronaCoinV1() external view returns (address) {
       return _carrier.ronaCoinV1();
    }
    
    function ronaCoinV2() external view returns (address) {
        return address(_coin);
    }

    function ronaCarrier() external view returns (address) {
        return address(_carrier);
    }

    function ronaCharityFeePercentage() external view returns (uint256) {
        return _carrier.charityFeePercentage();
    }

    function ronaHolderDistributionFeePercentage() external view returns (uint256) {
        return _carrier.holderDistributionFeePercentage();
    }

    function ronaLiquidityPoolingFeePercentage() external view returns (uint256) {
        return _carrier.liquidityPoolingFeePercentage();
    }

    function ronaTotalTransferFeePercentage() external view returns (uint256) {
        return _carrier.totalTransferFeePercentage();
    }

    function ronaCharityWalletAddress() external view returns (address) {
        return _carrier.charityWalletAddress();
    }

    function mintRonaCoin(uint256 amountToMint) public onlyOwner returns (bool) {
        _coin.mint(amountToMint);

        return true;
    }

    function burnRonaCoin(uint256 amountToBurn) public onlyOwner returns (bool) {
        _coin.burn(amountToBurn);

        return true;
    }

    function updateRonaCharityFeePercentage(uint256 newCharityFeePercentage) public onlyOwner returns (bool) {
        if(_carrier.updateCharityFeePercentage(newCharityFeePercentage)) {
            return _coin.updateTransferFeePercentage(_carrier.totalTransferFeePercentage());
        }

        return false;
    }

    function updateRonaHolderDistributionFeePercentage(uint256 newHolderDistributionFeePercentage) public onlyOwner returns (bool) {
        if(_carrier.updateHolderDistributionFeePercentage(newHolderDistributionFeePercentage)) {
            return _coin.updateTransferFeePercentage(_carrier.ronaTotalTransferFeePercentage());
        }

        return false;
    }

    function updateRonaLiquidityPoolingFeePercentage(uint256 newLiquidityPoolingFeePercentage) public onlyOwner returns (bool) {
       if(_carrier.updateLiquidityPoolingFeePercentage(newLiquidityPoolingFeePercentage)) {
           return _coin.updateTransferFeePercentage(_carrier.ronaTotalTransferFeePercentage());
       }

       return false;
    }

    function updateRonaCharityWalletAddress(address newCharityWalletAddress) public onlyOwner returns (bool) {
        return _carrier.updateCharityWalletAddress(newCharityWalletAddress);
    }
        
}