var Mintable = artifacts.require("./Mintable.sol");
var MintTokenProxy = artifacts.require("./MintTokenProxy.sol");

module.exports = function(deployer) {
  deployer.deploy(Mintable);
  deployer.deploy(MintTokenProxy);
};
