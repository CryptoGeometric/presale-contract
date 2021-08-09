//"SPDX-License-Identifier: MIT"
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/IPancakeFactory.sol";
import "./TokenTimelock.sol";

contract TokenSale is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    enum PresaleStatuses { Started, Canceled, Finished }

    uint constant public TOKEN_PRICE = 450 ether;
    uint constant public TOKEN_LISTING_PRICE = 300 ether;
    uint constant public LIQUIDITY_PERCENT = 50;
    uint constant public HARD_CAP = 400 ether;
    uint constant public SOFT_CAP = 0.2 ether;//40
    uint constant public CONTRIBUTION_MIN = 0.1 ether;
    uint constant public CONTRIBUTION_MAX = 10 ether;
    
    address public wBNB;
    address public LPTokenTimeLock;
    uint public fundersCounter;
    uint public totalSold;
    uint public tokenReminder;
    uint immutable public startTime;
    uint immutable public LPTokenLockUpTime;
    PresaleStatuses public status;

    mapping (address => uint) public funders;

    IPancakeRouter02 public pancakeRouter;
    IPancakeFactory private pancakeFactory;
    IERC20 public geometryToken;

    event Contribute(address funder, uint amount);

    constructor(
        uint _startTime,
        uint _LPTokenLockUpTime,
        IERC20 _geometryToken,
        address _pancakeRouter,
        address _wBNB
    )
    {
        startTime = _startTime;
        LPTokenLockUpTime = _LPTokenLockUpTime;
        geometryToken = _geometryToken;
        pancakeRouter = IPancakeRouter02(_pancakeRouter);
        address pancakeFactoryAddress = pancakeRouter.factory();
        pancakeFactory = IPancakeFactory(pancakeFactoryAddress);
        wBNB = _wBNB;
    }

    function contribute() public payable nonReentrant
    {
        require(msg.value >= CONTRIBUTION_MIN, "TokenSale: Contribution amount is too low!");
        require(msg.value < CONTRIBUTION_MAX, "TokenSale: Contribution amount is too high!");
        require(block.timestamp > startTime, "TokenSale: Presale is not started yet!");
        require(address(this).balance <= HARD_CAP, "TokenSale: Hard cap was reached!");
        require(
            status != PresaleStatuses.Finished &&
            status != PresaleStatuses.Canceled,
            "TokenSale: Presale is over!"
        );

        if (funders[_msgSender()] == 0) {
            funders[_msgSender()] = msg.value;
        } else {
            require(
                funders[_msgSender()] + msg.value <= CONTRIBUTION_MAX,
                "TokenSale: Contribution amount is too high, you was reached contribution maximum!"
            );
            funders[_msgSender()] += msg.value;
        }
        totalSold += msg.value * TOKEN_PRICE / 10 ** 18;
        emit Contribute(_msgSender(), msg.value);
    }

    function closePresale() public nonReentrant onlyOwner
    {
        require(status == PresaleStatuses.Started, "TokenSale: already closed");
        _setPresaleStatus(PresaleStatuses.Canceled);

        if (address(this).balance >= SOFT_CAP) {
            _addLiquidityOnPancake();
            _lockLPTokens();
            _setPresaleStatus(PresaleStatuses.Finished);
        }
    }

    function withdraw() public payable nonReentrant
    {
        require(status != PresaleStatuses.Started, "Launchpad: Presale is not finished");

        if (_msgSender() == owner()){
            if (status == PresaleStatuses.Finished) {
                _safeTransfer(geometryToken, owner(), tokenReminder);
                _safeTransferBNB(owner(), address(this).balance);
            } else if (status == PresaleStatuses.Canceled) {
                _safeTransfer(geometryToken, owner(), geometryToken.balanceOf(address(this)));
            }
        } else {
            require(funders[_msgSender()] != 0, "Launchpad: You are not a funder!");
            if (status == PresaleStatuses.Finished) {
                uint amount = funders[_msgSender()] * TOKEN_PRICE / 10 ** 18;
                funders[_msgSender()] = 0;
                _safeTransfer(geometryToken, _msgSender(), amount);
            } else if (status == PresaleStatuses.Canceled) {
                uint amount = funders[_msgSender()];
                funders[_msgSender()] = 0;
                _safeTransferBNB(_msgSender(), amount);
            }
        }
    }

    receive() external payable {
        _safeTransferBNB(owner(), msg.value);
    }
    
    function _addLiquidityOnPancake() private returns(uint amountA, uint amountB, uint liquidity)
    {
        uint amountTokenDesired = address(this).balance * TOKEN_LISTING_PRICE * LIQUIDITY_PERCENT / 100 / 10 ** 18;
        geometryToken.approve(address(pancakeRouter), amountTokenDesired);
        tokenReminder = geometryToken.balanceOf(address(this)) - amountTokenDesired - totalSold;

        uint amountBNB = address(this).balance * LIQUIDITY_PERCENT / 100;

        (amountA, amountB, liquidity) = pancakeRouter.addLiquidityETH{value: amountBNB}(
            address(geometryToken),
            amountTokenDesired,
            0,
            0,
            address(this),
            2**255
        );
    }

    function _lockLPTokens() private
    {
        address pair = pancakeFactory.getPair(address(geometryToken), wBNB);
        IERC20 LPToken = IERC20(pair);
        TokenTimelock contractInstance = new TokenTimelock(
            LPToken,
            owner(),
            LPTokenLockUpTime
        );

        LPTokenTimeLock = address(contractInstance);

        _safeTransfer(
            LPToken,
            LPTokenTimeLock,
            LPToken.balanceOf(address(this))
        );
    }

    function _setPresaleStatus(PresaleStatuses _status) private
    {
        status = _status;
    }

    function _safeTransferBNB(address _to, uint _value) internal {
        (bool success,) = _to.call{value:_value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }

    function _safeTransfer(IERC20 _token, address _to, uint _amount) private
    {
        _token.safeTransfer(_to, _amount);
    }
}
