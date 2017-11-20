const FluenceToken = artifacts.require("./FluenceToken.sol");

contract('FluenceToken', function (accounts) {
  it("should be renameable", async function () {
    const token = await FluenceToken.deployed();

    const s0 = await token.symbol()
    const n0 = await token.name()

    assert.equal(s0, "FPT(U)")
    assert.equal(n0, "Fluence Presale Token (Unlocked)")

    await token.rename("newSymbol", "newName")

    const s1 = await token.symbol()
    const n1 = await token.name()

    assert.equal(s1, "newSymbol")
    assert.equal(n1, "newName")

    try {
      await token.rename("newsNam22e", "newnSymb22ol", {from: accounts[1]})
    } catch (e) {
    }

    const s2 = await token.symbol()
    const n2 = await token.name()

    assert.equal(s2, "newSymbol")
    assert.equal(n2, "newName")
  })
});