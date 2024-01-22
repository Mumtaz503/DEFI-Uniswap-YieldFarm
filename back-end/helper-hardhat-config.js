
const networkConfig = {
    31337: {
        name: "localhost",
    },
    11155111: {
        name: "sepolia",
    },
}

const developmentChains = ["hardhat", "localhost"];
const swapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const poolFee = "3000";

module.exports = {
    networkConfig,
    developmentChains,
    swapRouterAddress,
    poolFee
}