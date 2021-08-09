//"SPDX-License-Identifier: MIT"
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
* ERC20 Token.
* Name: GEOMETRY COIN
* Symbol: GMTR
* Total supply: 10 000 000 CMC
* Decimals: 18
*
* https://eips.ethereum.org/EIPS/eip-20
*/
contract GeometryCoin is ERC20, Ownable {

    mapping (address => uint) public lastTransfers;
    mapping (address => uint) public lastIncomes;
    mapping (address => bool) public whiteList;

    /**
    * @notice Mint 10 000 000 GMTR tokens and send to owner
    */
    constructor() ERC20("GEOMETRY COIN", "GMTR") {
        _mint(owner(), 10000000 * 10 ** decimals());
    }

   /**
   * @notice Add to white list
   *
   * @param _address Member address of white list
   */
    function addToWhiteList(address _address) onlyOwner public {
        whiteList[_address] = true;
    }

    /**
   * @notice Remove from white list
   *
   * @param _address Member address of white list
   */
    function removeFromWhiteList(address _address) onlyOwner public {
        whiteList[_address] = false;
    }

    /**
    * @notice Burn your own tokens
    *
    * @param _amount Amount tokens for burn
    */
    function burnMyTokens(uint _amount) public {
        _burn(_msgSender(), _amount);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (!whiteList[recipient]) {
            lastTransfers[_msgSender()] = block.timestamp;
            lastIncomes[recipient] = block.timestamp;
        }
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
}
