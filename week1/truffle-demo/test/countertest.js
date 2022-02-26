const Counter = artifacts.require("counter");

contract("Counter", function(accounts){
    var counterInstance;
    it("Counter", function(){
        return Counter.deployed()
        .then(function (instance){
            return counterInstance.count();
        }).then(function(){
            return counterInstance.Counter();
        }).then(function(count){
            if(count1==1){
                print(1);
            }
            else
                print(2);
        })
    })
})
