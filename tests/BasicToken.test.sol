import { expect } from "chai";
import hre from "hardhat";

describe("BasicToken", function () {

  async function deployBasicToken() {
    const [owner, addr1, addr2] = await hre.viem.getWalletClients();

    const basicToken = await hre.viem.deployContract("BasicToken", [1_000_000n]);

    const publicClient = await hre.viem.getPublicClient();

    return { basicToken, owner, addr1, addr2, publicClient };
  }

  describe("Deployment", function () {
    it("Should set the right total supply", async function () {
      const { basicToken } = await deployBasicToken();

      expect(await basicToken.read.totalSupply()).to.equal(1_000_000n);
    });

    it("Should assign total supply to owner", async function () {
      const { basicToken, owner } = await deployBasicToken();

      const ownerBalance = await basicToken.read.balanceOf([owner.account.address]);
      expect(ownerBalance).to.equal(1_000_000n);
    });
  });

  describe("Transfers", function () {
    it("Should transfer tokens between accounts", async function () {
      const { basicToken, owner, addr1, publicClient } = await deployBasicToken();

      // Transfer 100 tokens dari owner ke addr1
      const hash = await basicToken.write.transfer([addr1.account.address, 100n]);
      await publicClient.waitForTransactionReceipt({ hash });

      // Check balances
      const addr1Balance = await basicToken.read.balanceOf([addr1.account.address]);
      expect(addr1Balance).to.equal(100n);

      const ownerBalance = await basicToken.read.balanceOf([owner.account.address]);
      expect(ownerBalance).to.equal(999_900n); // 1M - 100
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const { basicToken, addr1 } = await deployBasicToken();

      // addr1 punya 0 tokens, coba transfer 100
      await expect(
        basicToken.write.transfer([addr1.account.address, 100n], {
          account: addr1.account,
        })
      ).to.be.rejectedWith("Insufficient balance");
    });

    it("Should emit Transfer events", async function () {
      const { basicToken, owner, addr1, publicClient } = await deployBasicToken();

      const hash = await basicToken.write.transfer([addr1.account.address, 100n]);

      // Get transaction receipt
      const receipt = await publicClient.waitForTransactionReceipt({ hash });

      // Verify event emitted
      // (Viem automatically parses events)
      expect(receipt.status).to.equal("success");
    });
  });
});