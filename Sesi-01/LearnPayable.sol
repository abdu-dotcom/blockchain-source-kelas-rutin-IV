// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnPayable {
    uint256 public plantCounter;

    // Fungsi payable dapat menerima ETH
    function buyPlant() public payable returns (uint256) {
        require(msg.value >= 0.001 ether, "Perlu 0.001 ETH");

        plantCounter++;
        return plantCounter;
    }

    // Cek saldo contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}   