pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FluencePreSale.sol";

contract TestFluencePreSale {

  uint public initialBalance = 10 ether;

  function testSoftCap() {
    FluencePreSale fluence = FluencePreSale(DeployedAddresses.FluencePreSale());

    uint expected = 1000 ether;

    Assert.equal(fluence.softCap(), expected, "Soft cap must be 1000 ether");
  }

  function testContribute() {
    FluencePreSale fluence = new FluencePreSale(0, 100000000000);

    Assert.equal(fluence.owner(), tx.origin, "Owner must be set to sender");

    fluence.transfer.value(1 ether).gas(210000)();

    assert(fluence.balanceOf(tx.origin) == 1500);

    Assert.equal(fluence.balanceOf(tx.origin), 1500, "User should get 1500 FPT for 1 eth");
  }

}
