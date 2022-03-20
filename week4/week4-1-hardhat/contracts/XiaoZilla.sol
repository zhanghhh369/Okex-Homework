pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XiaoZilla is ERC20 {

    mapping(address => bool) public WhiteList;
    constructor() ERC20("XiaoZilla", "XiaoZilla") {
        _mint(msg.sender, 100 * 10 ** 18);
    }
}
