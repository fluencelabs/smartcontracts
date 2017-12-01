var FluenceToken = artifacts.require("./FluenceToken.sol");
var FluencePreSale = artifacts.require("./FluencePreSale.sol");
var FluencePreRelease = artifacts.require("./FluencePreRelease.sol");
var FakeCertifier = artifacts.require("./FakeCertifier.sol");

module.exports = function (deployer) {
  deployer.deploy(FluenceToken, 2*10**(18+7)).then(() => {
    deployer.deploy(FakeCertifier).then(() => {
      deployer.deploy(FluencePreRelease, FakeCertifier.address, FluencePreSale.address, FluenceToken.address);
    })
  });
};
