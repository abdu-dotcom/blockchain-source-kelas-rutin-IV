// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnFunctionModifiers {
    uint256 public counter = 0;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // VIEW: Membaca state, tidak mengubah (GRATIS!)
    function getCounter() public view returns (uint256) {
        return counter;  // Hanya baca
    }

    function getOwner() public view returns (address) {
        return owner;    // Hanya baca
    }

    function calculateDouble(uint256 x) public pure returns (uint256) {
        // Bisa baca state variable + parameter
        return x * 2;
    }

    // PURE: TIDAK baca dan TIDAK ubah state (GRATIS!)
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        // Hanya kalkulasi murni
        return a + b;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }

    // PAYABLE: Dapat menerima ETH
    function deposit() public payable {
        // Terima ETH tanpa kode
    }

    function buyItem() public payable returns (bool) {
        require(msg.value >= 0.001 ether, "Minimal 0.001 ETH");
        return true;
    }

    // REGULAR (no modifier): Mengubah state (BAYAR GAS!)
    function incrementCounter() public {
        counter++;  // Ubah state = butuh gas
    }

    function setCounter(uint256 _newValue) public {
        counter = _newValue;  // Ubah state = butuh gas
    }

    // Check balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}