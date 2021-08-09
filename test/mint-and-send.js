import ether from './helpers/ether';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const GeometryCoinContract = artifacts.require("GeometryCoin");

contract('GeometryCoin', async accounts => {

    let GeometryCoin;

    beforeEach(async function() {
        GeometryCoin = await GeometryCoinContract.deployed();
    });

    it('it is able to mint 10 000 000 GMTR', async function(){
        let totalSupply = await GeometryCoin.totalSupply();
        assert.equal(totalSupply.valueOf(), ether(10000000));
    });

    it('it is able to send 1 GMTR', async function(){
        let balance = await GeometryCoin.balanceOf(accounts[0]);
        assert.equal(balance.valueOf(), ether(10000000));

        let lastTransfer = await GeometryCoin.lastTransfers(accounts[0]);
        assert.equal(lastTransfer.valueOf(), 0);

        let lastIncomes = await GeometryCoin.lastIncomes(accounts[1]);
        assert.equal(lastIncomes.valueOf(), 0);

        await GeometryCoin.transfer(accounts[1], ether(1));

        balance = await GeometryCoin.balanceOf(accounts[0]);
        assert.equal(balance.valueOf(), ether(10000000 - 1));

        lastTransfer = await GeometryCoin.lastTransfers(accounts[0]);
        assert.notEqual(lastTransfer.valueOf(), 0);

        lastIncomes = await GeometryCoin.lastIncomes(accounts[1]);
        assert.notEqual(lastIncomes.valueOf(), 0, );

    });
});

