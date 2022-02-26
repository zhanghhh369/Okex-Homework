pragma solidity >=0.7.0 <0.9.0;

contract Counter {
    uint public counter;
    constructor () {
        counter=0;
    }
    function count() public{
        counter++;
    }
}
