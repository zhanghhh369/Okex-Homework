pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract CallOptionToken is ERC20, Ownable {
    using SafeERC20 for IERC20;

    uint256 public price;
    address public USDT;
    uint256 public exerciseTime;
    uint256 public constant during = 1 days;

    constructor(address _USDT) ERC20("CallOptionToken", "COT") {
        USDT = _USDT;
        price = 100;
        exerciseTime = block.timestamp + 1 days;
    }

    function mint() external payable onlyOwner {
        _mint(msg.sender, msg.value);
    }

    function exercise(uint256 amount) external {//行权函数
        //如果过期或不到期，都无法行权
        require(block.timestamp < exerciseTime + during, "INVALID_TIME: TOO EARLY");
        require(block.timestamp >= exerciseTime, "INVALID_TIME: TOO LATE");

        _burn(msg.sender, amount);
        uint256 totalPrice = price * amount;
        IERC20(USDT).safeTransferFrom(
            msg.sender,
            address(this),
            totalPrice
        );
        safeTransferETH(msg.sender, amount);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }

    function burnAll() external onlyOwner {//到期销毁
        require(block.timestamp >= exerciseTime + during, "INVALID_TIME: TOO EARLY");
        uint256 usdtAmount = IERC20(USDT).balanceOf(address(this));
        IERC20(USDT).safeTransfer(msg.sender, usdtAmount);

        selfdestruct(payable(msg.sender));
    }
}