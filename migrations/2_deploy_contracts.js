var FluencePreSale = artifacts.require("./FluencePreSale.sol");

module.exports = function(deployer) {
  deployer.deploy(FluencePreSale, 673000, 674000);
};
