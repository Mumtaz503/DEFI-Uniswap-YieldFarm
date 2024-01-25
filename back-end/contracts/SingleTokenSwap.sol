// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.7/interfaces/FeedRegistryInterface.sol";
import "./libraries/Denominations.sol";

contract SingleTokenSwap {
    /* Type Declarations */
    ISwapRouter public immutable i_swapRouter;
    FeedRegistryInterface public immutable feedRegistry;

    /* State variables */
    uint24 public immutable i_poolFee;

    /* Events */
    event assetLatestPrice(int price);

    constructor(
        ISwapRouter _iSwapRouter,
        uint24 _poolFee,
        address _registryAddress
    ) {
        i_swapRouter = _iSwapRouter;
        i_poolFee = _poolFee;
        feedRegistry = FeedRegistryInterface(_registryAddress);
    }

    /**
        1- I need to do calculations for "amountOutMinimum". For that I need two variables:
            a. Expected price of the _tokenOut which the user will get after the swap
            b. Slippage which occurs when the execution price deviates from expected price
               due to market fluctuations.
        2- To calculate the expected price, I need access to the liquidity pools of uniswap.
        3- To calculate slippage I need access to realtime market fluctuations by Chainlink.
     */

    function swapExactInputSingle(
        uint256 amountIn,
        address _tokenIn,
        address _tokenOut
    ) external returns (uint256 amountOut) {
        require(
            isValidErc20(_tokenIn) && isValidErc20(_tokenOut),
            "Not a valid ERC20 token"
        );

        uint256 expectedPrice = getExpectedPrice(_tokenIn, _tokenOut);

        uint256 slippageTolerance = 100;

        uint256 tokenOutMin = (expectedPrice * (1000 - slippageTolerance)) /
            1000;

        // Approve "_tokenIn" First in the front-end/scripts
        TransferHelper.safeTransferFrom(
            _tokenIn,
            msg.sender,
            address(this),
            amountIn
        );

        TransferHelper.safeApprove(_tokenIn, address(i_swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: i_poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: tokenOutMin,
                sqrtPriceLimitX96: 0
            });

        amountOut = i_swapRouter.exactInputSingle(params);
    }

    function swapExactOutputSingle(
        uint256 amountOut,
        uint256 amountInMaximum,
        address _tokenIn,
        address _tokenOut
    ) external returns (uint256 amountIn) {
        TransferHelper.safeTransferFrom(
            _tokenIn,
            msg.sender,
            address(this),
            amountInMaximum
        );

        TransferHelper.safeApprove(
            _tokenIn,
            address(i_swapRouter),
            amountInMaximum
        );

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: i_poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = i_swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(_tokenIn, address(i_swapRouter), 0);
            TransferHelper.safeTransfer(
                _tokenIn,
                msg.sender,
                amountInMaximum - amountIn
            );
        }
    }

    /* View and Pure functions for testing and help */

    function getExpectedPrice(
        address _tokenIn,
        address _tokenOut
    ) internal view returns (uint256) {
        require(
            IERC20Metadata(_tokenIn).decimals() ==
                IERC20Metadata(_tokenOut).decimals(),
            "Decimals Missmatch"
        );
        (, int tokenInPrice, , , ) = feedRegistry.latestRoundData(
            _tokenIn,
            Denominations.USD
        );

        (, int tokenOutPrice, , , ) = feedRegistry.latestRoundData(
            _tokenOut,
            Denominations.USD
        );

        uint256 expectedPrice = (uint256(tokenInPrice) *
            10 ** (uint256(IERC20Metadata(_tokenIn).decimals()))) /
            uint256(tokenOutPrice);

        return expectedPrice;
    }

    function isValidErc20(address _tokenAddress) public view returns (bool) {
        try IERC20Metadata(_tokenAddress).totalSupply() returns (uint256) {
            return true;
        } catch {
            return false;
        }
    }

    function getRouterAddress() public view returns (ISwapRouter) {
        return i_swapRouter;
    }

    function getPoolFee() public view returns (uint24) {
        return i_poolFee;
    }
}
