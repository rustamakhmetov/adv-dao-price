var DAONameContract = artifacts.require("DAONameContract");
var DAOToken = artifacts.require("DAOToken");

module.exports = function(deployer) {
    deployer.deploy(DAONameContract, DAOToken.address)
};