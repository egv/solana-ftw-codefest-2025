// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloWorld {
    string public message;
    address public owner;
    
    event MessageUpdated(string newMessage, address updatedBy);
    
    constructor() {
        message = "Привет, мир от Ethereum!";
        owner = msg.sender;
    }
    
    function setMessage(string memory _newMessage) public {
        message = _newMessage;
        emit MessageUpdated(_newMessage, msg.sender);
    }
    
    function getMessage() public view returns (string memory) {
        return message;
    }
}