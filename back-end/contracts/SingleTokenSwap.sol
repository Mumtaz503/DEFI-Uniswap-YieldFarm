// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract SingleTokenSwap {
    ISwapRouter public immutable i_swapRouter;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint24 public immutable i_poolFee;

    constructor(ISwapRouter _iSwapRouter, uint24 _poolFee) {
        i_swapRouter = _iSwapRouter;
        i_poolFee = _poolFee;
    }

    function swapExactInputSingle(
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        // Approve First
        TransferHelper.safeTransferFrom(
            DAI,
            msg.sender,
            address(this),
            amountIn
        );

        TransferHelper.safeApprove(DAI, address(i_swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH9,
                fee: i_poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = i_swapRouter.exactInputSingle(params);
    }

    function swapExactOutputSingle(
        uint256 amountOut,
        uint256 amountInMaximum
    ) external returns (uint256 amountIn) {
        TransferHelper.safeTransferFrom(
            DAI,
            msg.sender,
            address(this),
            amountInMaximum
        );

        TransferHelper.safeApprove(DAI, address(i_swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH9,
                fee: i_poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = i_swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(DAI, address(i_swapRouter), 0);
            TransferHelper.safeTransfer(
                DAI,
                msg.sender,
                amountInMaximum - amountIn
            );
        }
    }

    function getRouterAddress() public view returns (ISwapRouter) {
        return i_swapRouter;
    }

    function getPoolFee() public view returns (uint24) {
        return i_poolFee;
    }
}
