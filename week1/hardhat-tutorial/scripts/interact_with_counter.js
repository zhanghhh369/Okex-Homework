const {ethers, network} = require("hardhat")
const counterAddr = "0x40C1ac65f6DcE855b9119E5BbcB875320115699e"


async function main() {
    let owner = await ethers.getSigners;

    let counter = await ethers.getContractAt("Counter", counterAddr, owner);

    await counter.count();

    let newValue = await counter.counter();

    console.log("现在counter的值为", newValue);
}