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
        console.log("  Contract address: " + GeometryCoin.address);
        let totalSupply = await GeometryCoin.totalSupply();
        assert.equal(totalSupply.valueOf(), ether(10000000));
    });

});

