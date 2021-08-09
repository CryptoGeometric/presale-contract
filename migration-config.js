const now = Math.round(new Date() / 1000);

module.exports = {
    "development": {
        "startTime": now + 1,
        "LPTokenLockUpTime": now + 60,
        "pancakeRouter": "0x0000000000000000000000000000000000000000",
        "wBNB": "0x0000000000000000000000000000000000000000"
    },
    "bsc": {
        "startTime": 0,
        "LPTokenLockUpTime": 0,
        "pancakeRouter": "0x10ed43c718714eb63d5aa57b78b54704e256024e",
        "wBNB": "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c"
    },
    "rinkeby": {
        "startTime": now + 1,
        "LPTokenLockUpTime": now + 450,
        "pancakeRouter": "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
        "wBNB": "0xc778417E063141139Fce010982780140Aa0cD5Ab"
    }
}