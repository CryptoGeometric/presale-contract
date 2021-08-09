const Migrations = artifacts.require("Migrations");
const GeometryCoin = artifacts.require("GeometryCoin");
const TokenSale = artifacts.require("TokenSale");
const Config = require("../migration-config");

module.exports = async function(deployer, network) {
  process.env.NETWORK = network;
  await deployer.deploy(Migrations);
  await deployer.deploy(GeometryCoin);
  await deployer.deploy(
      TokenSale,
      Config[network]['startTime'],
      Config[network]['LPTokenLockUpTime'],
      GeometryCoin.address,
      Config[network]['pancakeRouter'],
      Config[network]['wBNB'],
  );
};
