import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomiclabs/hardhat-ethers";
import dotenv from 'dotenv';

dotenv.config();

const infuraKey = process.env.INFURA_KEY;
const privateKey = process.env.PRIVATE_KEY;
const networks = {};
const networkNames = ['mainnet','kovan','rinkeby','goerli','sepolia','aurora','aurora-test'];
if(infuraKey?.length) {
  networkNames.forEach(name => networks[name] = {
    url: `https://${name}.infura.io/v3/${infuraKey}`,
    accounts: [privateKey]
  });
}

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks,
};

export default config;
