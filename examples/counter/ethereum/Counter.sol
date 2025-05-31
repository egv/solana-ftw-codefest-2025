// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint256 public count;
    address public owner;
    
    event CountIncremented(uint256 newCount, address incrementedBy);
    event CountDecremented(uint256 newCount, address decrementedBy);
    event CountReset(address resetBy);
    
    constructor() {
        count = 0;
        owner = msg.sender;
    }
    
    function increment() public {
        count += 1;
        emit CountIncremented(count, msg.sender);
    }
    
    function decrement() public {
        require(count > 0, "Счетчик не может быть отрицательным");
        count -= 1;
        emit CountDecremented(count, msg.sender);
    }
    
    function reset() public {
        require(msg.sender == owner, "Только владелец может сбросить счетчик");
        count = 0;
        emit CountReset(msg.sender);
    }
    
    function getCount() public view returns (uint256) {
        return count;
    }
}