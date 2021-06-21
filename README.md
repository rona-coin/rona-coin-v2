# Rona Coin Version 2
This project contains source code for the Rona Coin V2 BEP-20 token and other associated smart contracts / scripts. Learn more about the Rona Coin project online at [ronacoin.io](https://ronacoin.io)!

Source code for and more information regarding the Rona Coin V1 token, currently deployed on the BSC Mainnet, can be found on GitHub [here](https://github.com/rona-coin/rona-coin-v1).

## About This Source Code
This project is structured around Node JS and Truffle. A solidity pragma of `^0.8.4` is used for all smart contract source code. The `Byzantium` build of SolC version `^0.8.4`, locally installed on a Windows 10 Pro machine, was used for all smart contract compilation for both the BSC Testnet and Mainnet.

This project's Node JS `package.json` configuration file can be found in its standard location at the root of the source directory. This project relies on the the following Node JS dependencies:
* `@truffle/hdwallet-provider ^1.4.0`
* `solc ^0.8.4`
* `truffle ^5.3.8`
* `web3 ^1.3.6`

This project's `package.json` also specifies a compile script to ensure stable and normal solidity compilation. This project's Truffle configuration for both the BSC Testnet and Mainnet can be found in the `truffle-config.js` file located at the project's root. The following basic network configuration for the smart chain is used and matches the [suggested configuration found within Binance's documentation](https://docs.binance.org/smart-chain/developer/deploy/truffle.html#config-truffle-for-bsc):
```
networks: {

    testnet: {
        provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`),
        network_id: 97,
        confirmations: 10,
        timeoutBlocks: 200,
        skipDryRun: true
    },

    mainnet: {
        provider: () => new HDWalletProvider(mnemonic, `https://bsc-dataseed1.binance.org`),
        network_id: 56,
        confirmations: 10,
        timeoutBlocks: 200,
        skipDryRun: true
    }

}
```

### `Callable`, `Buildable`, and `Ownable Contexts`
*Documentation to be added soon!*

### `RonaCoinV2`
This smart contract, source code for which can be found in the `contracts/RonaCoinV2.sol` file, implements the core BEP-20 token behaviors of Rona Coin V2 as discussed within [Binance's documentation on the token type](https://docs.binance.org/smart-chain/developer/BEP20.html). As such, this smart contract implements the `IBEP20` interface. Source code for this interface can be found in the `contracts/interfaces/IBEP20.sol` file.

To the furthest extent possible, the `RonaCoinV2` smart contract is designed to operate as a super simple, bog-standard, run of the mill, BEP-20 token. A "carrier" contract is used to assist with the processing of transactions. This gives the `RonaCoinV2` processing logic the ability to be updated should the future need for such a fix arrise. In a worst-case scenario, the carrier address for `RonaCoinV2` can be set to the `0` address. This would have the effect of immediatly reverting the coin to a stable holding state until any nessisary fixes can be fully implemented. 

### `ICarrier`
The `ICarrier` interface, defined in the `contracts/interfaces/ICarrier.sol` file, provides a standard method through which the `RonaCoinV2` smart contract can call and access the `RonaCarrier` contract which implements Rona Coin specific functionality.

The `ICarrier` interface requires that a carrier smart contract implement the following method:
```
function carry(address from, address to, uint256 amount) public returns (bool);
```
This `carry` method is called from within the coin's transfer logic. During this method call, transaction fees are handled / distributed according to the coin's individual tokenomics model. 

### `RonaCarrier`
*Documentation to be added soon!*

### `RonaLab`
*Documentation to be added soon!*
