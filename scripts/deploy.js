// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Everly = await ethers.getContractFactory("Everly");
  const everly = await Everly.deploy("EVERLY_NFT", "EVE");

  await everly.deployed();

  console.log("Successfully deployed to:", everly.address);

  await everly.mint("https://gateway.pinata.cloud/ipfs/QmTdi4aEwYQbe2TgsyU52ZcqFWnNUQ65LzehCktmebY1CQ");
  console.log("NFT Successfully minted");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
