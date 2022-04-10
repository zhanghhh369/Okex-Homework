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
    address public factory;

    constructor() {
        token0 = 0xBBF7b4794f8b76e4A948d2Acb06DDC0cF463415f;
        token1 = 0xA11f15fA81f9848987F8eA4624F01B2F3784FBe4;
        router = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a;
        to = 0x8Dcf5C1E2826F68d4b753c923C3501c12DD737d5;
        weth = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
        factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
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
        //IERC20(token0).safeApprove(msg.sender, amountIn);
        //value1 = IERC20(token0).allowance(token0, msg.sender);
        IERC20(token0).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(token0).approve(address(this), amountIn);
        //value2 = IERC20(token0).allowance(token0, address(this));

        IERC20(token0).approve(router, amountIn);
        //value3 = IERC20(token0).allowance(token0, router);
        //emit event1(value);
        IUniswapV2Router01(router).swapExactTokensForTokens(amountIn, minTokenAmount, path, to, block.timestamp);
    }
}
