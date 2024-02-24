import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Vault", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployVaultFixture() {
    const [owner, accountOne, accountTwo, accountThree, accountFour] = await ethers.getSigners();

    const Vault = await ethers.getContractFactory("Vault");
    const vault = await Vault.deploy();

    return { vault, owner, accountOne, accountTwo, accountThree, accountFour };
  }

  describe("Deployment", function () {
    it("Should set the deployer address as owner", async function () {
      const { vault, owner } = await loadFixture(deployVaultFixture);

      expect(await vault.owner()).to.equal(owner.address);
    });
  });
});
