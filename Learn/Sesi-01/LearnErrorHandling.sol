// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnErrorHandling {
    address public owner;
    uint256 public balance;
    mapping(address => uint256) public userBalance;

    constructor() {
        owner = msg.sender;
        balance = 100;
    }

    // REQUIRE: Validasi input dan kondisi (yang paling umum!)
    function withdraw(uint256 amount) public {
        // Validasi 1: Cek saldo cukup
        require(balance >= amount, "Saldo tidak cukup");

        // Validasi 2: Cek amount tidak 0
        require(amount > 0, "Amount harus lebih dari 0");

        // Jika semua require pass, jalankan
        balance -= amount;
        userBalance[msg.sender] += amount;
    }

    function deposit(uint256 amount) public {
        require(amount > 0, "Harus deposit lebih dari 0");

        balance += amount;
    }

    // Require dengan kondisi kompleks
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Hanya owner");
        require(newOwner != address(0), "Address tidak valid");
        require(newOwner != owner, "Sudah jadi owner");

        owner = newOwner;
    }

    // REVERT: Manual error dengan kondisi custom
    function checkEven(uint256 number) public pure returns (bool) {
        if (number % 2 != 0) {
            revert("Angka harus genap!");
        }
        return true;
    }

    function complexCheck(uint256 value) public pure returns (string memory) {
        if (value < 10) {
            revert("Nilai terlalu kecil");
        }
        if (value > 100) {
            revert("Nilai terlalu besar");
        }
        if (value == 50) {
            revert("Nilai 50 tidak diperbolehkan");
        }

        return "Nilai valid!";
    }

    // ASSERT: Internal error checking (jarang dipakai)
    function internalCheck(uint256 newBalance) public {
        balance = newBalance;

        // Assert untuk cek invariant (kondisi yang HARUS selalu benar)
        // Jika assert gagal = ada BUG di code!
        assert(balance >= 0);  // uint256 selalu >= 0, ini contoh saja
    }
}