const { getNamedAccounts, ethers, deployments, network } = require("hardhat");
const {
  swapRouterAddress,
  poolFee,
  developmentChains,
} = require("../../../helper-hardhat-config");
const { assert } = require("chai");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Single Token Swap unit tests", function () {
      let singleTokenSwap, daiToken, wethToken, deployer, user, signer;

      beforeEach(async () => {
        deployer = (await getNamedAccounts()).deployer;
        user = (await getNamedAccounts()).user;
        signer = await ethers.provider.getSigner();
        await deployments.fixture(["SingleTokenSwap"]);
        singleTokenSwap = await ethers.getContract("SingleTokenSwap", deployer);
        daiToken = await ethers.getContractAt(
          "IERC20",
          "0x6B175474E89094C44Da98b954EedeAC495271d0F",
          signer
        );
        wethToken = await ethers.getContractAt(
          "IERC20",
          "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
          signer
        );
      });

      describe("Constructor", () => {
        it("Should set the swap router address and pool fee correctly", async function () {
          const routerAddress = await singleTokenSwap.getRouterAddress();
          const poolFees = await singleTokenSwap.getPoolFee();
          assert.equal(routerAddress, swapRouterAddress);
          assert.equal(poolFee, poolFees);
        });
      });

      describe("swapExactInputSingle", () => {
        beforeEach(async function() {
            const tokenAmount = ethers.parseEther("100");
            const tx = await daiToken.transfer(deployer, tokenAmount);
            await tx.wait(1);
        });

        it("Should update the balance", async function() {
            const balanceOfDeployer = await daiToken.balanceOf(deployer);
            console.log(balanceOfDeployer);
        });
      });
    });
