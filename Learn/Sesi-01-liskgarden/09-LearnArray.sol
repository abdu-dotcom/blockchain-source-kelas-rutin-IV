// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnArray {
    // Array untuk menyimpan plant ID
    uint256[] public allPlantIds;

    // Tambah tanaman
    function addPlant(uint256 _plantId) public {
        allPlantIds.push(_plantId);
    }

    // Dapatkan total tanaman
    function getTotalPlants() public view returns (uint256) {
        return allPlantIds.length;
    }

    // Dapatkan semua plant ID
    function getAllPlants() public view returns (uint256[] memory) {
        return allPlantIds;
    }
}