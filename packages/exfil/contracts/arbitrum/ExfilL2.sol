// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.11;

import "./Arbsys.sol";
import "../Exfil.sol";

contract ExfilL2 is Exfil {
    ArbSys constant arbsys = ArbSys(100);
    address public l1Target;

    event L2ToL1TxCreated(uint256 indexed withdrawalId);

    constructor(string memory _message, address _l1Target)
        public
        Exfil(_message)
    {
        l1Target = _l1Target;
    }

    function updateL1Target(address _l1Target) public {
        l1Target = _l1Target;
    }

    // TODO: CHANGE THIS TO "SEND_INITIATE_EXFIL_MESSAGE"
    function setMessageInL1(string memory _message) public returns (uint256) {
        bytes memory data =
            abi.encodeWithSelector(Exfil.setMessage.selector, _message);

        uint256 withdrawalId = arbsys.sendTxToL1(l1Target, data);

        emit L2ToL1TxCreated(withdrawalId);
        return withdrawalId;
    }

    // Only l1Target can update greeting
    function setMessage(string memory _message) public override {
        require(msg.sender == l1Target, "Message only updateable by L1");
        Exfil.setMessage(_message);
    }
}
