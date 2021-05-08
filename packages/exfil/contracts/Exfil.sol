pragma solidity ^0.6.11;

contract Exfil {
    string message;

    constructor(string memory _message) public {
        message = _message;
    }

    function message() public view returns (string memory) {
        return message;
    }

    function setMessage(string memory _message) public virtual {
        message = _message;
    }
}
