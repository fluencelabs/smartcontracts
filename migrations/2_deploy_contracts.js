var FluencePreSale = artifacts.require("./FluencePreSale.sol");

module.exports = function(deployer) {
  deployer.deploy(FluencePreSale, 1, 674000, 1000);
};
