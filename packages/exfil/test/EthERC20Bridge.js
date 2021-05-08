const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EthERC20Bridge", function () {
  it("Should successfully do a fast withdrawal from L2 to L1", async function () {
    const [takerAddress, makerAddress] = await ethers.getSigners();
    const EthERC20Bridge = await ethers.getContractFactory("EthERC20Bridge");
    const bridge = await EthERC20Bridge.deploy();
    await bridge.fastWithdrawalFromL2(
      makerAddress,
      "proof",
      takerAddress,
      100,
      1
    );
  });
});
