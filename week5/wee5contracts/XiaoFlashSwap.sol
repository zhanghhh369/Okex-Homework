pragma solidity ^0.8.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IWETH.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';

contract XiaoFlashSwap is IUniswapV2Callee {
    IUniswapV3Factory immutable factoryV3;
    address immutable factory;

    constructor(address _factoryV2, address _factoryV3, address _V2router, address _V3Manager, address _V3SwapRouter) public {
        factoryV3 = IUniswapV3Factory(_factoryV3);
        NonfungiblePositionManager = INonfungiblePositionManager(_V3Manager);
        V3SwapRouter = ISwapRouter(_V3SwapRouter);
        factoryV2 = _factoryV2;
        V2router = IUniswapV2Router01(_V2router);
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
        assert(msg.sender == UniswapV2Library.pairFor(factory, token0, token1)); // ensure that msg.sender is actually a V2 pair
        assert(amount0 == 0 || amount1 == 0); // this strategy is unidirectional
        path[0] = amount0 == 0 ? token0 : token1;
        path[1] = amount0 == 0 ? token1 : token0;
        }

        IERC20 token0 = IERC20(path[0]);
        IERC20 token1 = IERC20(path[1]);

        if (amount1 > 0) {
            //(uint minETH) = abi.decode(data, (uint)); // slippage parameter for V1, passed in by caller
            // 套利
            token1.approve(address(V3SwapRouter), amount1);

            uint amountReceived = V3SwapRouter.exactInputSingle(token1, token0, 0, msg.sender, block.timestamp, amount1, amount0, state.sqrtPriceX96);

            uint amountRequired = UniswapV2Library.getAmountsIn(factory, amountToken, path[0]);
            assert(amountReceived > amountRequired); // fail if we didn't get enough ETH back to repay our flash loan
            assert(token0.transfer(msg.sender, amountRequired)); // return tokens to V2 pair
            assert(token0.transfer(sender, amountReceived - amountRequired)); // keep the rest! (tokens)
        }
    }
}
