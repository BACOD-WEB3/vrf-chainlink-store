import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.12",

  networks: {
    mumbai: {
      url: process.env.ROPSTEN_URL || "",
      // gasPrice: 20000000000,
      // gas: 6000000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    wallaby: {
      url: "https://wallaby.node.glif.io/rpc/v0",
      // gasPrice: 20000000000,
      // gas: 6000000,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  // gasReporter: {
  //   enabled: process.env.REPORT_GAS !== undefined,
  //   currency: "USD",
  // }
};

export default config;
