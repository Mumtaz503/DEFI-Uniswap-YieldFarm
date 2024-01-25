const { network } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  log("-----------------------------------------------------------");
  log("Deploying Test Token contractt...");

  await deploy("ERC20Test", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log("-----------------------------------------------------------");
};

module.exports.tags = ["ERC20Test"];
