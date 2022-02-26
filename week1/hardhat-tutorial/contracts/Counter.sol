pragma solidity >=0.7.0 <0.9.0;

import  "hardhat/console.sol";

contract Counter {
    uint public counter;
    constructor (uint initValue) {
        counter=initValue;
    }
    function count() public{
        counter++;
        console.log("counter num:", counter);
    }
}
