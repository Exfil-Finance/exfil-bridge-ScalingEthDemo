pragma solidity ^0.6.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./IExitLiquidityProvider.sol";
import "./Inbox.sol";

import "./Outbox.sol";

contract EthERC20Bridge {
    using SafeERC20 for IERC20;

    address internal constant USED_ADDRESS = address(0x01);

    // exitNum => exitDataHash => LP
    mapping(bytes32 => address) redirectedExits;

    address public l2Address;
    IInbox public inbox;

    function initialize(address _inbox, address _l2Address) external payable {
        l2Address = _l2Address;
        inbox = IInbox(_inbox);
    }

    function fastWithdrawalFromL2(
        address liquidityProvider,
        bytes memory liquidityProof,
        address erc20,
        uint256 amount,
        uint256 exitNum
    ) public {
        IOutbox outbox = IOutbox(inbox.bridge().activeOutbox());
        address msgSender = outbox.l2ToL1Sender();

        bytes32 withdrawData =
            keccak256(abi.encodePacked(exitNum, msgSender, erc20, amount));
        require(
            redirectedExits[withdrawData] == USED_ADDRESS,
            "ALREADY_EXITED"
        );
        redirectedExits[withdrawData] = liquidityProvider;

        IExitLiquidityProvider(liquidityProvider).requestLiquidity(
            msgSender,
            erc20,
            amount,
            exitNum,
            liquidityProof
        );
    }
}
