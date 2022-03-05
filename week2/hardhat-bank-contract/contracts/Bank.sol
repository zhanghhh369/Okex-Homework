pragma solidity ^0.8.0;

contract Bank{
    event logdata(uint x);
    uint total;
    mapping(address => uint) public balances;

    constructor() payable {
    }

    // 这是一个回调函数, 收到以太币会被调用
    receive() external payable {
      emit logdata(msg.value);
      if(balances[msg.sender]==0){
        update(msg.value);
      }
      else{
        deposit(msg.value);
      }
      total += msg.value;
    }

    function update(uint newBalance) public {
        balances[msg.sender] = newBalance;
    }

    function deposit(uint money) public {
        balances[msg.sender] += money;
    }

    function saveTransferEth(address addr) public payable{
        (bool success, ) = addr.call{value: total}("");
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdrawAll(address addr) public {
        saveTransferEth(addr);
    }

}
