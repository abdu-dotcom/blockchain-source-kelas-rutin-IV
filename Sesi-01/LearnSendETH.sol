// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnSendETH {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Terima ETH
    function deposit() public payable {}

    // Kirim ETH ke seseorang
    function sendReward(address _to) public {
        require(msg.sender == owner, "Hanya owner");

        // Kirim 0.001 ETH
        (bool success, ) = _to.call{value: 0.001 ether}("");
        require(success, "Transfer gagal");
    }

    // Cek saldo
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}