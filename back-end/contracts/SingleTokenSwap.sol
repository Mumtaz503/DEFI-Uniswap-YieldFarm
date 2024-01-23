// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract SingleTokenSwap {
    IERC20 public erc20;
    ISwapRouter public immutable i_swapRouter;

    uint24 public immutable i_poolFee;

    constructor(ISwapRouter _iSwapRouter, uint24 _poolFee) {
        i_swapRouter = _iSwapRouter;
        i_poolFee = _poolFee;
    }

    function swapExactInputSingle(
        uint256 amountIn,
        address _tokenIn,
        address _tokenOut
    ) external returns (uint256 amountOut) {
        
        require(isValidErc20(_tokenIn) && isValidErc20(_tokenOut), "Not a valid ERC20 token");

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
                amountOutMinimum: 10,
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

    function isValidErc20(address _tokenAddress) public view returns (bool){
        try IERC20(_tokenAddress).totalSupply() returns (uint256) {
            return true;
        } catch  {
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
