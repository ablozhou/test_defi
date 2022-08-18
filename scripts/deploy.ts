import { ethers, artifacts } from "hardhat";
//我们智能合约中的代码被编译为称为字节码和ABI的“工件”(artifacts)。
import { BigNumber } from "@ethersproject/bignumber"
import * as path from "path"
async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const TWO_MIN = 2 * 60;
  const unlockTimeYear = currentTimestampInSeconds + ONE_YEAR_IN_SECS;
  const unlockTime = currentTimestampInSeconds + TWO_MIN;
  const etherAmount = "100"
  const lockedAmount: BigNumber = ethers.utils.parseEther(etherAmount);

  const Lock = await ethers.getContractFactory("Lock");
  const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  await lock.deployed();

  console.log("Lock with %d ETH deployed to: %s", lockedAmount, lock.address);

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy();
  await token.deployed();
  console.log("Token was deployed to address: %s", token.address);

  //saveFrontendFiles(token);
}

function saveFrontendFiles(token: any) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "src", "artifacts", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "contract-address.json"),
    JSON.stringify({ Token: token.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync("Token");

  fs.writeFileSync(
    path.join(contractsDir, "Token.json"),
    JSON.stringify(TokenArtifact, null, 2)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
