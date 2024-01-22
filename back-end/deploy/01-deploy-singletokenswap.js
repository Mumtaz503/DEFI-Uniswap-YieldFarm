const { network, ethers } = require("hardhat");
const {
  developmentChains,
  swapRouterAddress,
  poolFee,
} = require("../helper-hardhat-config");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  const constructorArgs = [swapRouterAddress, poolFee];

  log("-----------------------------------------------------------");
  log("Deploying SingleTokenSwap contract please wait...");

  await deploy("SingleTokenSwap", {
    from: deployer,
    args: constructorArgs,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  log(`Single Token Swap contract successfully deployed!!`);
  log("-----------------------------------------------------------");
};

module.exports.tags = ["SingleTokenSwap"];
