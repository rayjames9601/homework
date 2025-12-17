// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 銀行介面
/// @notice 定義銀行合約需實作的最小介面
interface IBank {
    /// @notice 取得銀行管理員位址
    function owner() external view returns (address);

    /// @notice 由管理員提領指定數量資金
    /// @param amount 提領金額（wei）
    function withdraw(uint256 amount) external;
}

/// @title 基礎銀行合約
/// @notice 實作 IBank，支援存款與管理員提領
contract Bank is IBank {
    /// @notice 銀行管理員
    address public override owner;

    /// @notice 每個地址的存款餘額
    mapping(address => uint256) public balances;

    /// @notice 存款金額前 3 名的使用者位址
    address[3] public top3;

    constructor() {
        owner = msg.sender;
    }

    /// @notice 僅限管理員的限制
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    /// @notice 接收 ETH 存款，並更新排行榜
    receive() external payable virtual {
        balances[msg.sender] += msg.value;
        _updateTop3(msg.sender);
    }

    /// @notice 內部函式：更新前 3 名存款使用者
    /// @param user 本次存款的使用者
    function _updateTop3(address user) internal {
        // 若已在 top3 中則不需更新
        for (uint256 i = 0; i < 3; i++) {
            if (top3[i] == user) {
                return;
            }
        }

        // 找出目前 top3 中存款最少者
        uint256 minIndex = 0;
        for (uint256 i = 1; i < 3; i++) {
            if (balances[top3[i]] < balances[top3[minIndex]]) {
                minIndex = i;
            }
        }

        // 只有當 user 的餘額大於最小者時才替換進排行榜
        if (balances[user] > balances[top3[minIndex]]) {
            top3[minIndex] = user;
        }
    }

    /// @notice 管理員從合約提領指定金額到呼叫者位址
    /// @dev 此處資金會轉到 msg.sender，因此當 Admin 合約成為 owner 時，
    ///      透過 Admin 呼叫 withdraw()，資金即會轉入 Admin 合約位址。
    /// @param amount 提領金額（wei）
    function withdraw(uint256 amount) external override onlyOwner {
        require(amount <= address(this).balance, "insufficient balance");
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
    }
}

/// @title 大額銀行合約
/// @notice 繼承自 Bank，要求存款大於 0.001 ether，且支援轉移管理員
contract BigBank is Bank {
    /// @notice 限制存款金額必須大於 0.001 ether
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "deposit too small");
        _;
    }

    /// @notice 覆寫接收 ETH 的行為，加入最低存款限制
    receive() external payable override minDeposit {
        balances[msg.sender] += msg.value;
        _updateTop3(msg.sender);
    }

    /// @notice 將銀行管理員權限轉移給新位址
    /// @param newOwner 新的管理員位址（不可為 0）
    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero address");
        owner = newOwner;
    }
}

/// @title 管理員合約
/// @notice 管理員可從任意實作 IBank 的銀行合約提領資金到本合約
contract Admin {
    /// @notice Admin 合約的擁有者
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /// @notice 僅限 Admin 擁有者
    modifier onlyOwner() {
        require(msg.sender == owner, "not admin owner");
        _;
    }

    /// @notice 從指定的 IBank 銀行合約提領資金到本合約
    /// @dev 前提：該 Bank/BigBank 的 owner 必須已設定為本 Admin 合約位址。
    /// @param bank 目標銀行合約
    /// @param amount 提領金額（wei）
    function adminWithdraw(IBank bank, uint256 amount) external onlyOwner {
        bank.withdraw(amount);
    }

    /// @notice Admin 擁有者從本合約提領資金
    /// @param amount 提領金額（wei）
    function withdrawFromAdmin(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "insufficient balance");
        (bool ok, ) = payable(owner).call{value: amount}("");
        require(ok, "transfer failed");
    }

    /// @notice 接收來自銀行或外部的 ETH
    receive() external payable {}
}


