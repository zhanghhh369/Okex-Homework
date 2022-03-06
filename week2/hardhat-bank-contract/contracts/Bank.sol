pragma solidity ^0.8.0;

contract Bank{
    event logdata(uint x);
    uint total;
    mapping(address => uint) public balances;
    address[] addrs;

    constructor() payable {
    }

    // 收到以太币会被调用
    receive() external payable {
      emit logdata(msg.value);
      //如果是第一次转钱，则初始化map
      if(balances[msg.sender]==0){
        update(msg.value);
        addrs.push(msg.sender);
      }
      //如果是多次转钱，则加钱
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

    function saveTransferEth(address userAddr) public payable{
        (bool success, ) = userAddr.call{value: total}("");
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }

    function getBalance(address userAddr) public view returns (uint) {
        return balances[userAddr];
    }

    function withdrawAll(address userAddr) public {
        uint len = addrs.length;
        for (uint i = 0; i < len; i++) {
            balances[addrs[i]] = 0;
            remove(i);
        }
        saveTransferEth(userAddr);
    }

    function remove(uint index) public {
        uint len = addrs.length;
        if (index == len - 1) {
            addrs.pop();
        } else {
            addrs[index] = addrs[len - 1];
            addrs.pop();
        }
    }

}
