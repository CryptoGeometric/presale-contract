export default function ether (n) {
  return web3.utils.toBN(web3.utils.toWei(n.toString(), 'ether')).toString();
}
