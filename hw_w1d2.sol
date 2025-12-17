// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    // 紀錄計數值
    uint256 private counter;

    // 讀取計數
    function get() external view returns (uint256) {
        return counter;
    }

    // 增加指定數值
    function add(uint256 x) external {
        counter += x;
    }
}

