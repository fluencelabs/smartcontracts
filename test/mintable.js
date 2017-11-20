const MintTokenProxy = artifacts.require("./MintTokenProxy.sol");
const Mintable = artifacts.require("./Mintable.sol");

contract('FluenceToken', function (accounts) {


  it("should allow/deny minting to owner", async function() {
    const token = await Mintable.deployed();

    // Initially, there's no supply
    const s = await token.totalSupply()
    assert.equal(s, 0)

    // Try to mint by owner
    try {
      await token.mint(accounts[1], 1000)
    } catch(e) {
    }
    // Try to allow minting by wrong account
    try {
      await token.allowMinting(accounts[3], {from: accounts[1]})
    } catch(e) {
    }
    // Try to mint by another account
    try {
      await token.mint(accounts[1], 1000, {from: accounts[3]})
    } catch(e) {
    }

    // Total supply and balance should be intact
    const s1 = await token.totalSupply()
    assert.equal(s1, 0)

    const b0 = await token.balanceOf(accounts[1])
    assert.equal(b0, 0)

    // Allow minting for one account
    await token.allowMinting(accounts[3])

    // Try mint from wrong account
    try {
      await token.mint(accounts[1], 1000)
    } catch(e) {
    }

    // Balances should be intact
    const s2 = await token.totalSupply()
    assert.equal(s2, 0)

    const b1 = await token.balanceOf(accounts[1])
    assert.equal(b1, 0)

    // Try to mint from wrong (non-owner) account
    try {
      await token.mint(accounts[1], 1000, {from: accounts[1]})
    } catch(e) {
    }

    // Balances should be intact
    const s3 = await token.totalSupply()
    assert.equal(s3.valueOf(), 0)

    const b2 = await token.balanceOf(accounts[1])
    assert.equal(b2.valueOf(), 0)

    // Try to mint from correct account
    await token.mint(accounts[1], 1000, {from: accounts[3]})

    // Supply should be changed
    const s4 = await token.totalSupply()
    assert.equal(s4.valueOf(), 1000)

    const b3 = await token.balanceOf(accounts[1])
    assert.equal(b3.valueOf(), 1000)

    // Deny minting by wrong account
    try {
      await token.denyMinting(acounts[3], {from: accounts[3]})
    } catch(e){}

    await token.mint(accounts[1], 1000, {from: accounts[3]})
    const s5 = await token.totalSupply()
    assert.equal(s5.valueOf(), 2000)

    // Deny minting
    await token.denyMinting(accounts[3])
    try {
      await token.mint(accounts[1], 1000, {from: accounts[3]})
    } catch(e){}
    const s6 = await token.totalSupply()
    assert.equal(s6.valueOf(), 2000)
  })

  it("should mint correctly via proxy", async function(){
    const token = await Mintable.deployed();
    const proxy = await MintTokenProxy.deployed();
    await proxy.setToken(token.address)

    await token.allowMinting(proxy.address)

    const s0 = await token.totalSupply()
    assert.equal(s0.valueOf(), 2000)

    try {
      await token.mint(accounts[0], 1000)
    } catch(e){}

    const s1 = await token.totalSupply()
    assert.equal(s1.valueOf(), 2000)

    await proxy.mint(accounts[4], 1000)

    const s2 = await token.totalSupply()
    assert.equal(s2.valueOf(), 3000)

    const b0 = await token.balanceOf(accounts[4])
    assert.equal(b0.valueOf(), 1000)

    await token.denyMinting(proxy.address)
    try {
      await proxy.mint(accounts[4], 1000)
    } catch(e){}

    const s3 = await token.totalSupply()
    assert.equal(s3.valueOf(), 3000)

  })

  it("should deny minting after all", async function(){
    const token = await Mintable.deployed();

    const s3 = await token.totalSupply()
    assert.equal(s3.valueOf(), 3000)

    // Allow minting again
    await token.allowMinting(accounts[1])
    // Finish minting
    await token.finishMinting()
    // Can't mint anymore
    try {
      await token.mint(accounts[1], 1000, {from: accounts[3]})
    } catch(e){}
    const s7 = await token.totalSupply()
    assert.equal(s7.valueOf(), 3000)
  })
});