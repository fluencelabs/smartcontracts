pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FluencePreSale.sol";

contract TestFluencePreSale {

  uint public initialBalance = 10 ether;
  uint public gasLimit = 500000;

  function testSoftCap() {
    FluencePreSale fluence = FluencePreSale(DeployedAddresses.FluencePreSale());

    uint expected = 1000 ether;

    Assert.equal(fluence.softCap(), expected, "Soft cap must be 1000 ether");
  }

}
