var FluenceToken = artifacts.require("./FluenceToken.sol");
var MintTokenProxy = artifacts.require("./MintTokenProxy.sol");

module.exports = function(deployer) {
  deployer.deploy(FluenceToken);
  deployer.deploy(MintTokenProxy);
};
