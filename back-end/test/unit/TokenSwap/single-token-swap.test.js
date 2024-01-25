const { getNamedAccounts, ethers, deployments, network } = require("hardhat");
const {
  swapRouterAddress,
  poolFee,
  developmentChains,
} = require("../../../helper-hardhat-config");
const { assert, expect } = require("chai");

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
          "IErc20",
          "0x6B175474E89094C44Da98b954EedeAC495271d0F",
          signer
        );
        wethToken = await ethers.getContractAt(
          "IErc20",
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
          //Buying DAI tokens from UniswapV2Router2 (For a separate test)
          const amountOutMin = 8;
          const path = [
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", //WETH
            "0x6B175474E89094C44Da98b954EedeAC495271d0F", //DAI
          ];
          const deadline = Math.floor(Date.now() / 1000) + 60 * 10; //10 min from now. I guess

          const transactionResponse = await routerv2.swapExactETHForTokens(
            amountOutMin,
            path,
            deployer,
            deadline,
            {
              value: ethers.parseEther("1"),
            }
          );
          await transactionResponse.wait(1);

          //Buying WETH from WETH9 token contract
          const tx = await wethToken.deposit({
            value: ethers.parseEther("10"),
          });
          await tx.wait(1);
        });

        it("Should revert if the passed token Address is not ERC20", async function () {
          const amountWethToSend = ethers.parseEther("10");
          const tokenOut = daiToken.target;
          await expect(
            singleTokenSwap.swapExactInputSingle(
              amountWethToSend,
              routerv2, //Passing a falsy address for an ERC20 token
              tokenOut
            )
          ).to.be.revertedWith("Not a valid ERC20 token");
        });

        it("Should swap specified incoming tokens for outgoing tokens", async function () {
          const tokenOut = wethToken.target;
          const tokenIn = daiToken.target;
          const amountWethToSend = ethers.parseEther("10");
          const deployerWethBalance = await wethToken.balanceOf(deployer);

          await daiToken.approve(singleTokenSwap.target, amountWethToSend);
          const tx = await singleTokenSwap.swapExactInputSingle(
            amountWethToSend,
            tokenIn,
            tokenOut
          );
          await tx.wait(1);

          const deployerWethBalanaceAfter = await wethToken.balanceOf(deployer);
          assert(deployerWethBalanaceAfter > deployerWethBalance);
        });
        // Remaining tests
      });
      describe("isValidErc20 function", () => {
        it("is valid erc20", async function () {
          const isValidErc20 = await singleTokenSwap.isValidErc20(
            daiToken.target
          );
          expect(isValidErc20).to.be.true;
        });
      });
    });
