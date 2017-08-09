const FluencePreSale = artifacts.require("./FluencePreSale.sol");

contract('FluencePreSale', function(accounts) {
  it("should be able to contribute 1 eth", async function() {
    const instance = await FluencePreSale.deployed();

    const tx = await instance.sendTransaction({from: accounts[0], value: web3.toWei(1, 'ether')})

    const tokensBalance = await instance.balanceOf(accounts[0])
    assert.equal(tokensBalance.toNumber(), 1500 * (10 ** 18), "Balance should be 1500 * 10^18")

    const ethCollected = await instance.etherCollected()
    assert.equal(ethCollected.toNumber(), 1 * (10**18), "etherCollected should be 1 ether");

    const tokensIssued = await instance.totalSupply()
    assert.equal(tokensIssued.toNumber(), 1500 * (10**18), "totalSupply should be 1500 ether");

    })

  it("should be able to contribute 5 eth", async function() {
    const instance = await FluencePreSale.deployed();

    const tx = await instance.sendTransaction({from: accounts[1], value: web3.toWei(5, 'ether')})

    const tokensBalance = await instance.balanceOf(accounts[1])
    assert.equal(tokensBalance.toNumber(), 2250 * 5 * (10 ** 18), "Balance should be 2250 * 5 * 10^18")

    const ethCollected = await instance.etherCollected()
    assert.equal(ethCollected.toNumber(), 6 * (10**18), "etherCollected should be 6 ether");

    const tokensIssued = await instance.totalSupply()
    assert.equal(tokensIssued.toNumber(), (2250 * 5 + 1500) * (10**18), "totalSupply should be 2250 * 5 ether");

    })

  it("should not be able to contribute 0.1 eth", async function() {
    const instance = await FluencePreSale.deployed();

    try {
      await instance.sendTransaction({from: accounts[2], value: web3.toWei(100, 'finney')})
    } catch(e) {
      return;
    }
    assert.equal(1, 0, "Exception was not thrown on 0.1 eth contribution")

    })
  });