const hre = require("hardhat");

async function main() {
  const USDT = await hre.ethers.getContractFactory("USDT");
  const usdt = await USDT.deploy();
  await USDT.deployed();
  console.log("USDT已部署:", usdt.address);

  const CallOptionToken = await hre.ethers.getContractFactory("CallOptionToken");
  const callOptionToken = await CallOptionToken.deploy(usdt.address);
  await CallOptionToken.deployed();
  console.log("看涨期权币已部署:", callOptionToken.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });