// Rona Coin Version 2
// truffle-config.js
// Developed by Stew, May-June 2021

// SPDX-License-Identifier: MIT

const fs = require('fs');
const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
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
  },
  compilers: {
    solc: {
      version: "^0.8.4",
      docker: false,
      settings: {
         optimizer: {
            enabled: false
        },
        evmVersion: "byzantium"
      }
    }
  },
  db: {
    enabled: false
  }
};
