// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnNumber {
    // Angka untuk data tanaman
    uint256 public plantId;
    uint256 public waterLevel;

    constructor() {
        plantId = 1;
        waterLevel = 100;
    }

    function changePlantId(uint256 _newId) public {
        plantId = _newId;
    }

    function addWater() public {
        waterLevel = waterLevel + 10;
        // Bisa juga ditulis: waterLevel += 10;
    }
}