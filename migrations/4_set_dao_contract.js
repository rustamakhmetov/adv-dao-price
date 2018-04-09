var DAOContract = artifacts.require("DAOPriceContract");
var DAOToken = artifacts.require("DAOToken");

module.exports = function(deployer) {
    async function setContract() {
        let token = await DAOToken.deployed();
        await token.setDAOContract(DAOContract.address);
        return true;
    }

    setContract().then(v => {
        console.log("Set dao contract: ", v);  // prints 60 after 2 seconds.
    });
};
