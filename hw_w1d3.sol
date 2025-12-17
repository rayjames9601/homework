// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;
    address[3] public top3;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        updateTop3(msg.sender);
    }

    function updateTop3(address user) internal {
        for (uint i = 0; i < 3; i++) {
            if (top3[i] == user) return;
        }

        uint min = 0;
        for (uint i = 1; i < 3; i++) {
            if (balances[top3[i]] < balances[top3[min]]) {
                min = i;
            }
        }

        if (balances[user] > balances[top3[min]]) {
            top3[min] = user;
        }
    }

    function withdraw(uint amount) external onlyOwner {
        payable(owner).transfer(amount);
    }
}
