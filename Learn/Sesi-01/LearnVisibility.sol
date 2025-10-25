// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnVisibility {
    // STATE VARIABLES VISIBILITY
    uint256 public publicVar = 100;      // Otomatis ada getter
    uint256 private privateVar = 200;    // Hanya contract ini
    uint256 internal internalVar = 300;  // Contract ini + turunan

    // PUBLIC: Bisa dipanggil dari mana saja
    function publicFunction() public pure returns (string memory) {
        return "Semua bisa panggil ini";
    }

    // EXTERNAL: Hanya dari LUAR contract (tidak bisa dipanggil internal)
    function externalFunction() external pure returns (string memory) {
        return "Hanya bisa dipanggil dari luar";
    }

    // INTERNAL: Hanya dari contract ini dan turunannya
    function internalFunction() internal pure returns (string memory) {
        return "Hanya untuk internal";
    }

    // PRIVATE: HANYA contract ini
    function privateFunction() private pure returns (string memory) {
        return "Hanya contract ini";
    }

    // Fungsi untuk test internal call
    function testInternalCall() public pure returns (string memory) {
        // Bisa panggil internal function
        return internalFunction();
    }

    // Fungsi untuk akses private variable
    function getPrivateVar() public view returns (uint256) {
        return privateVar;  // Bisa akses karena dalam contract yang sama
    }
}