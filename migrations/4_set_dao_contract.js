var DAONameContract = artifacts.require("DAONameContract");
var DAOToken = artifacts.require("DAOToken");

module.exports = function(deployer) {
    async function setContract() {
        let token = await DAOToken.deployed();
        await token.setDAOContract(DAONameContract.address);
        return true;
    }

    setContract().then(v => {
        console.log("Set dao contract: ", v);  // prints 60 after 2 seconds.
    });
};
