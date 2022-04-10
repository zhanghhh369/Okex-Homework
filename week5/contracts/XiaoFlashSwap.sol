pragma solidity >=0.6.6;

import './libraries/UniswapV2Library.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';

contract XiaoFlashSwap is IUniswapV2Callee {
    IUniswapV3Factory immutable factoryV3;
    address immutable factoryV2;
    ISwapRouter immutable V3SwapRouter;

    constructor(address _factoryV2, address _factoryV3, address _V3SwapRouter) public {
        factoryV3 = IUniswapV3Factory(_factoryV3);
        V3SwapRouter = ISwapRouter(_V3SwapRouter);
        factoryV2 = _factoryV2;
    }

    // needs to accept ETH from any V1 exchange and WETH. ideally this could be enforced, as in the router,
    // but it's not possible because it requires a call to the v1 factory, which takes too much gas
    receive() external payable {}

    // gets tokens/WETH via a V2 flash swap, swaps for the ETH/tokens on V1, repays V2, and keeps the rest!
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        address[] memory path = new address[](2);
        { // scope for token{0,1}, avoids stack too deep errors
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        //assert(msg.sender == UniswapV2Library.pairFor(factoryV2, token0, token1)); // ensure that msg.sender is actually a V2 pair
        assert(amount0 == 0 || amount1 == 0); // this strategy is unidirectional
        path[0] = amount0 == 0 ? token0 : token1;
        path[1] = amount0 == 0 ? token1 : token0;
        }

        IERC20 token0 = IERC20(path[0]);
        IERC20 token1 = IERC20(path[1]);

        if (amount1 > 0) {
            //(uint minETH) = abi.decode(data, (uint)); // slippage parameter for V1, passed in by caller
            // 套利

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: address(token1),
                tokenOut: address(token0),
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amount1,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0

            });
            token1.approve(address(V3SwapRouter), type(uint).max);

            uint amountReceived = V3SwapRouter.exactInputSingle(params);

            uint amountRequired = UniswapV2Library.getAmountsIn(factoryV2, amount1, path)[0];
            assert(amountReceived > amountRequired); // fail if we didn't get enough ETH back to repay our flash loan
            assert(token0.transfer(msg.sender, amountRequired)); // return tokens to V2 pair
            assert(token0.transfer(tx.origin, amountReceived - amountRequired)); // keep the rest! (tokens)
        }
    }
}
