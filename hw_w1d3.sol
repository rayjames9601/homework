// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Bank is Ownable {

    address[3] public topUsers;

    mapping(address => uint) deposited;

    constructor() Ownable(msg.sender) {}

    function renewTopUsers(address _user) internal {
        for (uint i = 0; i < 3; i++){
            if (topUsers[i] == _user){
                return ;
            }
        }

        for (uint i = 0; i < 3; i++){
            if (topUsers[i] == address(0)){
                topUsers[i] = _user;
                return ;
            }
        }

        uint lowestIndex = findLowestIndex();

        if (deposited[_user] > deposited[topUsers[lowestIndex]]){
            topUsers[lowestIndex] = _user;

        }

    }

    function findLowestIndex() internal view returns(uint) {
        uint lowestIndex = 0;
        for (uint i = 1; i < 3; i++){
            if(deposited[topUsers[i]] < deposited[topUsers[lowestIndex]]){
                lowestIndex = i;
            }
        }
        return lowestIndex;
    }

    function withdraw() external onlyOwner {
        // payable(owner()).transfer(address(this).balance);
        (bool sent, ) = payable(owner()).call{value: address(this).balance}("");
        require(sent);
    }


    receive() external payable { 
        require(msg.value > 0);
        deposited[msg.sender] += msg.value;
        renewTopUsers(msg.sender);


    }
}