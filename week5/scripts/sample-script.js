// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const XiaoFlashSwap = await hre.ethers.getContractFactory("XiaoFlashSwap");
  const flashSwap = await XiaoFlashSwap.deploy("0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f","0xf164fC0Ec4E93095b804a4795bBe1e041497b92a","0xE592427A0AEce92De3Edee1F18E0157C05861564");

  await flashSwap.deployed();

  console.log("flashSwap deployed to:", flashSwap.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
