// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice 簡化版 ERC20 介面，用於存取 Token
interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract TokenBank {
    /// @notice 目標 Token 位址
    IERC20 public immutable token;

    /// @notice 記錄每個地址已存入的數量
    mapping(address => uint256) public deposits;

    constructor(IERC20 _token) {
        token = _token;
    }

    /// @notice 存入 Token；需要先在 Token 合約對本合約授權
    /// @param amount 存入數量
    function deposit(uint256 amount) external {
        require(amount > 0, "amount must be > 0");
        require(token.transferFrom(msg.sender, address(this), amount), "transferFrom failed");
        deposits[msg.sender] += amount;
    }

    /// @notice 提取此前存入的 Token
    /// @param amount 提取數量
    function withdraw(uint256 amount) external {
        require(amount > 0, "amount must be > 0");
        require(deposits[msg.sender] >= amount, "insufficient deposit");
        deposits[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "transfer failed");
    }
}

