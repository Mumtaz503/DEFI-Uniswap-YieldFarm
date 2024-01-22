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
      let singleTokenSwap,
        daiToken,
        wethToken,
        deployer,
        user,
        signer,
        routerv2;

      beforeEach(async () => {
        deployer = (await getNamedAccounts()).deployer;
        user = (await getNamedAccounts()).user;
        signer = await ethers.provider.getSigner();
        await deployments.fixture(["SingleTokenSwap"]);
        singleTokenSwap = await ethers.getContract("SingleTokenSwap", deployer);
        daiToken = await ethers.getContractAt(
          "ERC20Interface",
          "0x6B175474E89094C44Da98b954EedeAC495271d0F",
          signer
        );
        wethToken = await ethers.getContractAt(
          "ERC20Interface",
          "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
          signer
        );
        routerv2 = await ethers.getContractAt(
          "UniswapV2Router02",
          "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
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
        beforeEach(async function () {
          const amountOutMin = 100;
          const path = [
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            "0x6B175474E89094C44Da98b954EedeAC495271d0F",
          ];
          const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

          const transactionResponse = await routerv2.swapExactETHForTokens(
            amountOutMin,
            path,
            deployer,
            deadline,
            {
              value: ethers.parseEther("1")
            }
          );

          const transactionReciept = await transactionResponse.wait(1);
        });

        it("Should update the balance", async function () {
          const amountToSend = 100;
          const approval = await daiToken.approve(singleTokenSwap.target, amountToSend);
          console.log(approval);
          const tx = await singleTokenSwap.swapExactInputSingle(amountToSend);
          await tx.wait(1);
          //Figure out why I'm not getting my WETH
        });
      });
    });
