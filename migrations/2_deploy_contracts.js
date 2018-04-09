var DAOToken = artifacts.require("DAOToken");

module.exports = function(deployer) {
    deployer.deploy(DAOToken)
};