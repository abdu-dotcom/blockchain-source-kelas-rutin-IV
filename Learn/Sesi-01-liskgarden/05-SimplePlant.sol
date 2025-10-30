// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract SimplePlant {
    // TODO 1: Deklarasikan 5 state variables
    // Hint: string public plantName;
    // Hint: uint256 public ...
    // ... tulis 4 lainnya!
    string public plantName;
    uint256 public waterLevel;
    bool public isAlive;
    address public owner;
    uint256 public plantedTime;

    // TODO 2: Buat constructor
    constructor() {
        // Set nilai awal untuk semua variables
        // Hint: plantName = "Rose";
        // Hint: owner = msg.sender;
        plantName = "Rose";
        waterLevel = 100;
        isAlive = true;
        owner = msg.sender;
        plantedTime = block.timestamp;
    }

    // TODO 3: Buat fungsi water()
    // Hint: function water() public { ... }
    function water() public {
        waterLevel = 100;
    }

    // TODO 4: Buat fungsi getAge()
    // Hint: function getAge() public view returns (uint256) { ... }
    // Hint: return block.timestamp - plantedTime;
    function getAge() public view returns (uint256) {
        return block.timestamp - plantedTime;
    }
}