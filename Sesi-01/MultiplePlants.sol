// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MultiplePlants {
    enum GrowthStage { SEED, SPROUT, GROWING, BLOOMING }

    struct Plant {
        uint256 id;
        address owner;
        GrowthStage stage;
        uint8 waterLevel;
        bool exists;
    }

    // Mapping untuk menyimpan tanaman
    mapping(uint256 => Plant) public plants;

    // Counter
    uint256 public plantCounter;

    // Tambah tanaman baru
    function addPlant() public returns (uint256) {
        plantCounter++;

        plants[plantCounter] = Plant({
            id: plantCounter,
            owner: msg.sender,
            stage: GrowthStage.SEED,
            waterLevel: 100,
            exists: true
        });

        return plantCounter;
    }

    // Siram tanaman
    function waterPlant(uint256 _plantId) public {
        plants[_plantId].waterLevel = 100;
    }

    // Dapatkan info tanaman
    function getPlant(uint256 _plantId) public view returns (Plant memory) {
        return plants[_plantId];
    }
}