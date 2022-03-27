pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MyTokenMarket {
    using SafeERC20 for IERC20;

    address public token0;
    address public token1;
    address public to;
    address public router;
    address public weth;

    constructor(address _token0, address _token1, address _router, address _weth, address _to) {
        token0 = _token0;
        token1 = _token1;
        router = _router;
        to = _to;
        weth = _weth;
    }

    // 添加流动性
    // function AddLiquidity(uint tokenAmount) public payable {
    //     IERC20(myToken).safeTransferFrom(msg.sender, address(this),tokenAmount);
    //     IERC20(myToken).safeApprove(router, tokenAmount);

    //     // ingnore slippage
    //     // (uint amountToken, uint amountETH, uint liquidity) = 
    //     IUniswapV2Router01(router).addLiquidityETH{value: msg.value}(myToken, tokenAmount, 0, 0, msg.sender, block.timestamp);

    //     //TODO: handle left
    // }

    // 用 ETH 购买 Token
    // function buyToken(uint minTokenAmount) public payable {
    //     address[] memory path = new address[](2);
    //     path[0] = weth;
    //     path[1] = myToken;

    //     IUniswapV2Router01(router).swapExactETHForTokens{value : msg.value}(minTokenAmount, path, msg.sender, block.timestamp);
    // }

    function SwapTokenWithCallee(uint amountIn, uint minTokenAmount) public payable {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        IUniswapV2Router01(router).swapExactTokensForTokens(amountIn, minTokenAmount, path, to, block.timestamp);
    }
}
