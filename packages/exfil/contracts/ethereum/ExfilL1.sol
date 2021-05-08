// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.11;

import "./Outbox.sol";
import "./Inbox.sol";
import "../Exfil.sol";

contract ExfilL1 is Exfil {
    address public l2Target;
    IInbox public inbox;

    event RetryableTicketCreated(uint256 indexed ticketId);

    constructor(
        string memory _message,
        address _l2Target,
        address _inbox
    ) public Exfil(_message) {
        l2Target = _l2Target;
        inbox = IInbox(_inbox);
    }

    function updateL2Target(address _l2Target) public {
        l2Target = _l2Target;
    }

    function setMessageInL2(
        string memory _message,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid
    ) public payable returns (uint256) {
        bytes memory data =
            abi.encodeWithSelector(Exfil.setGreeting.selector, _greeting);

        uint256 ticketID =
            inbox.createRetryableTicket{value: msg.value}(
                l2Target,
                0,
                maxSubmissionCost,
                msg.sender,
                msg.sender,
                maxGas,
                gasPriceBid,
                data
            );

        emit RetryableTicketCreated(ticketID);
        return ticketID;
    }

    /// @notice only l2Target can update message
    // TODO: CHANGE THIS TO GET INITIATE EXFIL MESSAGE FROM L2, AND KICKOFF ORACLE VERIFICATION WITH STATE/WITHDRAWAL TX ID
    // RETURNS A BOOL (ISVALIDWITHDRAWAL)
    // IF ISVALID == TRUE, CALL INIT FAST WITHDRAWAL ON ETHERC20BRIDGE.SOL with proof and address of LP contract
    function setMessage(string memory _message) public override {
        IOutbox outbox = IOutbox(inbox.bridge().activeOutbox());
        address l2Sender = outbox.l2ToL1Sender();
        require(l2Sender == l2Target, "Message only updateable by L2");

        Exfil.setMessage(_message);
    }
}
