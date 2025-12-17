// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    address public owner;

    // 每个地址的存款金额
    mapping(address => uint256) public balanceOf;

    // 存款前三名（不排序）
    address[3] public top3;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /* ========== 存款逻辑 ========== */

    receive() external payable {
        require(msg.value > 0, "zero deposit");

        balanceOf[msg.sender] += msg.value;
        _updateTop3(msg.sender);
    }

    /* ========== 更新前三名 ========== */

    function _updateTop3(address user) internal {
        // 1. 如果已经在 top3，直接返回
        for (uint i = 0; i < 3; i++) {
            if (top3[i] == user) {
                return;
            }
        }

        // 2. 找到当前 top3 中余额最小的索引
        uint minIndex = 0;
        uint minBalance = balanceOf[top3[0]];

        for (uint i = 1; i < 3; i++) {
            if (balanceOf[top3[i]] < minBalance) {
                minBalance = balanceOf[top3[i]];
                minIndex = i;
            }
        }

        // 3. 如果新用户余额更大，替换最小的
        if (balanceOf[user] > minBalance) {
            top3[minIndex] = user;
        }
    }


    function withdraw() external onlyOwner {
        uint amount = address(this).balance;
        require(amount > 0, "no eth");

        (bool ok, ) = payable(owner).call{value: amount}("");
        require(ok, "withdraw failed");
    }


    function getTop3() external view returns (address[3] memory) {
        return top3;
    }
}
