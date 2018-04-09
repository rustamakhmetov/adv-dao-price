var DAOContract = artifacts.require("DAOPriceContract");
var DAOToken = artifacts.require("DAOToken");

module.exports = function(deployer) {
    deployer.deploy(DAOContract, DAOToken.address)
};