// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.11;

import "./Outbox.sol";
import "./Inbox.sol";
import "../Greeter.sol";

contract GreeterL1 is Greeter {
    address public l2Target;
    IInbox public inbox;

    event RetryableTicketCreated(uint256 indexed ticketId);

    constructor(
        string memory _greeting,
        address _l2Target,
        address _inbox
    ) public Greeter(_greeting) {
        l2Target = _l2Target;
        inbox = IInbox(_inbox);
    }

    function updateL2Target(address _l2Target) public {
        l2Target = _l2Target;
    }

    function setGreetingInL2(
        string memory _greeting,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid
    ) public payable returns (uint256) {
        bytes memory data =
            abi.encodeWithSelector(Greeter.setGreeting.selector, _greeting);

        uint256 ticketID = inbox.createRetryableTicket{value: msg.value}(
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

    /// @notice only l2Target can update greeting
    // TODO: CHANGE THIS TO GET INITIATE EXFIL MESSAGE FROM L2, AND KICKOFF ORACLE VERIFICATION WITH STATE/WITHDRAWAL TX ID
    // RETURNS A BOOL (ISVALIDWITHDRAWAL)
    // IF ISVALID == TRUE, CALL INIT FAST WITHDRAWAL ON ETHERC20BRIDGE.SOL with proof and address of LP contract
    function setGreeting(string memory _greeting) public override {
        IOutbox outbox = IOutbox(inbox.bridge().activeOutbox());
        address l2Sender = outbox.l2ToL1Sender();
        require(l2Sender == l2Target, "Greeting only updateable by L2");

        Greeter.setGreeting(_greeting);
    }
}
