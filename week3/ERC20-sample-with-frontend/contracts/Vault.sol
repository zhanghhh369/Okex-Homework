// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Vault {
    mapping(address => uint) public balances;
    address public immutable token;

    constructor(address _token) {
        token = _token;
    }

    function permitDeposit(uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        IERC20Permit(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
        deposit(amount);
    }

    function permitWithdraw(uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        IERC20Permit(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
        withdraw(amount);
    }

    function deposit(uint amount) public {
        require(IERC20(token).transferFrom(msg.sender, address(this), _amountWithDecimal), "Transfer from error");
        balances[msg.sender] += _amountWithDecimal;
    }

    function withdraw(uint amount) public {
        uint256 _amountWithDecimal = amount * 10 ** 18;
        require(IERC20(token).transferFrom(address(this), msg.sender, amount), "Transfer from error");
        balances[msg.sender] -= _amountWithDecimal;
    }

    function queryBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

}

contract XiaoZilla is ERC20 {

    mapping(address => bool) public WhiteList;
    constructor() ERC20("XiaoZilla", "XiaoZilla") {
        _mint(msg.sender, 10000 * 10 ** 18);
    }
}