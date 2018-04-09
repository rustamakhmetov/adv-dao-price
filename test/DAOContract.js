require('chai').use(require('chai-as-promised')).should();
const Reverter = require('./helpers/reverter');
const Asserts = require('./helpers/asserts');
const DAOContract = artifacts.require('DAOPriceContract');
const DAOToken = artifacts.require('DAOToken');

contract('DAOContract', function(accounts) {
    const reverter = new Reverter(web3);
    afterEach('revert', reverter.revert);

    let simple_dao;
    let token;
    let current_price = web3.toWei(0.01, "ether");
    let proposal_price = web3.toWei(0.05, "ether");
    const ERROR_MSG = 'VM Exception while processing transaction: revert';

    before('setup', () => {
        DAOToken.deployed()
            .then(instance => token = instance);
        return DAOContract.deployed()
            .then(instance => simple_dao = instance)
            .then(reverter.snapshot);
    });

    it('buy tokens', async function() {
        for(let i=0; i<2; i++) {
            let account = web3.eth.accounts[i];

            let account_balance = (await token.balanceOf(account)).toNumber();
            assert.equal(account_balance, 0, 'account balance should be 0');

            let result = await token.buy({from: account, value: web3.toWei(0.01, "ether")});
            account_balance = (await token.balanceOf(account)).toNumber();
            assert.equal(account_balance, 1, 'account balance should be 1 token (with considering decimals)');
        }
    });

    it('new price', async function(){
        let voteActive = (await simple_dao.voteActive());
        let price = (await token.buyPrice());
        assert.isFalse(voteActive);
        assert.equal(price, current_price);

        await simple_dao.newPrice(proposal_price);
        voteActive = (await simple_dao.voteActive());
        assert.isTrue(voteActive);
        price = (await token.buyPrice());
        assert.equal(price, current_price);
    });

    it('vote', async function() {
        let account = web3.eth.accounts[0];

        await token.buy({from: account, value: web3.toWei(0.01, "ether")}); // 1 token
        await simple_dao.newPrice(proposal_price);
        // первое голосование
        await simple_dao.vote(true, {from: account});
        let election = (await simple_dao.election());
        assert.equal(election[0].toNumber(), 1); //current
        assert.equal(election[1].toNumber(), 1); //numberOfVotes
        // запрещено повторное голосование
        await simple_dao.vote(false, {from: account}).should.be.rejectedWith(ERROR_MSG); // ловим require
        election = (await simple_dao.election());
        assert.equal(election[0].toNumber(), 1); //current
        assert.equal(election[1].toNumber(), 1); //numberOfVotes
    });

    it('change price', async function() {
        // покупка токенов до начала голосования
        // 1 аккаунт
        let account1 = web3.eth.accounts[0];
        await token.buy({from: account1, value: web3.toWei(0.01, "ether")}); // 1 token
        // 2 аккаунт
        let account2 = web3.eth.accounts[1];
        await token.buy({from: account2, value: web3.toWei(0.05, "ether")}); // 5 token
        let account_balance = (await token.balanceOf(account2)).toNumber();
        assert.equal(account_balance, 5, 'account balance should be 5');
        // старт голосования
        await simple_dao.newPrice(proposal_price);

        // покупка токенов в момент голосования - запрещена
        let account3 = web3.eth.accounts[2];
        await token.buy({from: account3, value: web3.toWei(0.05, "ether")}).should.be.rejectedWith(ERROR_MSG);

        // голосование 1го аккаунта
        await simple_dao.vote(true, {from: account1});
        let election = (await simple_dao.election());
        assert.equal(election[0].toNumber(), 1); //current
        assert.equal(election[1].toNumber(), 1); //numberOfVotes
        // недостаточно голосов
        await simple_dao.changePrice().should.be.rejectedWith(ERROR_MSG); // ловим require

        // голосование 2го аккаунта
        await simple_dao.vote(true, {from: account2});
        // проверка на кол-во голосом
        election = (await simple_dao.election());
        assert.equal(election[0].toNumber(), 6); //current
        assert.equal(election[1].toNumber(), 6); //numberOfVotes
        // меняем имя
        await simple_dao.changePrice();
        let price = (await token.buyPrice());
        assert.equal(price, proposal_price);

        // проверяем очистку DAO переменных
        let voteActive = (await simple_dao.voteActive());
        assert.isFalse(voteActive);
        election = (await simple_dao.election());
        assert.equal(election[0].toNumber(), 0); //current
        assert.equal(election[1].toNumber(), 0); //numberOfVotes
        let _proposalPrice = (await simple_dao.proposalPrice());
        assert.equal(_proposalPrice, 0);
    });

});