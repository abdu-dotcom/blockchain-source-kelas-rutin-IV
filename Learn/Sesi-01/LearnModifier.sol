// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnModifier {
    address public owner;
    mapping(uint256 => address) public plantOwner;
    mapping(uint256 => uint8) public waterLevel;
    uint256 public ownerActionCount;

    constructor() {
        owner = msg.sender;
    }

    // Modifier: hanya owner yang bisa memanggil
    modifier onlyOwner() {
        require(msg.sender == owner, "Hanya owner!");
        _;
    }

    // Modifier: harus memiliki tanaman
    modifier onlyPlantOwner(uint256 _plantId) {
        require(plantOwner[_plantId] == msg.sender, "Bukan tanaman Anda!");
        _;
    }

    function addPlant(uint256 _plantId) public {
        plantOwner[_plantId] = msg.sender;
        waterLevel[_plantId] = 100;
    }

    // Hanya owner yang bisa memanggil ini
    function ownerFunction() public onlyOwner {
        ownerActionCount++;
    }

    // Hanya pemilik tanaman yang bisa menyiram
    function waterPlant(uint256 _plantId) public onlyPlantOwner(_plantId) {
        waterLevel[_plantId] = 100;
    }
}