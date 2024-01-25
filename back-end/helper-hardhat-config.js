const networkConfig = {
  31337: {
    name: "localhost",
    swapRouterAddress: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
    priceFeedRegistry: "0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf",
    poolFee: "3000",
  },
  11155111: {
    name: "sepolia",
    swapRouterAddress: "",
    priceFeedRegistry: "",
    poolFee: "",
  },
};

const developmentChains = ["hardhat", "localhost"];

module.exports = {
  networkConfig,
  developmentChains,
};
