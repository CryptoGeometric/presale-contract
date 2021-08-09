import ether from './helpers/ether';
import EVMRevert from './helpers/EVMRevert';
const Config = require("../migration-config");

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const TokenSaleContract = artifacts.require("TokenSale");
const GeometryCoinContract = artifacts.require("GeometryCoin");

contract('TokenSale', async accounts => {

    const owner = accounts[0];
    const alice = accounts[1];
    const bob = accounts[2];
    const totalSupply = ether(10000000);
    const contribution = ether(0.1);

    let GeometryCoin;
    let TokenSale;
    let TimeLock;

    const network = process.env.NETWORK;

    beforeEach(async () => {
        TokenSale = await TokenSaleContract.deployed();
        const geometryCoinAddress = await TokenSale.geometryToken();
        GeometryCoin = await GeometryCoinContract.at(geometryCoinAddress);
    });

    it.only('check minted amount. It is should be equal 10 000 000 GMTR', async () => {
        const _totalSupply = await GeometryCoin.totalSupply();
        assert.equal(_totalSupply.valueOf(), totalSupply);
    });

    it.only('check initial variables', async () => {
        const startTime = await TokenSale.startTime();
        assert.equal(startTime.toString(), Config[network]['startTime']);

        const LPTokenLockUpTime = await TokenSale.LPTokenLockUpTime();
        assert.equal(LPTokenLockUpTime.toString(), Config[network]['LPTokenLockUpTime']);

        const geometryToken = await TokenSale.geometryToken();
        assert.equal(geometryToken.toString(), GeometryCoin.address);

        const pancakeRouter = await TokenSale.pancakeRouter();
        assert.equal(pancakeRouter.toString(), Config[network]['pancakeRouter']);

        const wBNB = await TokenSale.wBNB();
        assert.equal(wBNB.toString(), Config[network]['wBNB']);
    });

    it.only('should be able to deposit tokens', async () => {
        await GeometryCoin.transfer(
            TokenSale.address,
            totalSupply,
            { from: owner }
        );
        const balanceToken = await GeometryCoin.balanceOf(TokenSale.address);
        assert.equal(balanceToken.toString(), totalSupply.toString());
    });

    it.only('should be able to contribute BNB to presale from alice', async () => {
        await TokenSale.contribute({ from: alice, value: contribution });

        const contributedAmount = await TokenSale.funders(alice);
        assert.equal(contributedAmount, contribution);
    });

    it.only('contribution should be rejected with small amount', async () => {
        await TokenSale.contribute({ from: alice, value: ether(0.01) })
            .should
            .be
            .rejectedWith(EVMRevert);
    });

    it.only('contribution should be rejected during presale was not closed', async () => {
        await TokenSale.withdraw({ from: alice, value: 0 })
            .should
            .be
            .rejectedWith(EVMRevert);
    });




});

