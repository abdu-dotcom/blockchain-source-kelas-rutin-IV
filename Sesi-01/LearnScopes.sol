// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnScopes {
    // 1. STATE VARIABLE: Disimpan di blockchain storage
    uint256 public plantCounter;  // Permanen, tersimpan selamanya
    address public owner;         // Biaya gas untuk write/update

    // 2. GLOBAL VARIABLES: Built-in Solidity
    function getGlobalVariables() public view returns (
        address sender,
        uint256 timestamp,
        uint256 blockNumber,
        address contractAddress
    ) {
        sender = msg.sender;              // Alamat yang memanggil fungsi
        timestamp = block.timestamp;      // Waktu blok saat ini (Unix)
        blockNumber = block.number;       // Nomor blok saat ini
        contractAddress = address(this);  // Alamat contract ini

        return (sender, timestamp, blockNumber, contractAddress);
    }

    // 3. LOCAL VARIABLES: Temporary dalam function
    function calculateAge(uint256 _plantedTime) public view returns (uint256) {
        // Local variable - hanya ada selama fungsi berjalan
        uint256 currentTime = block.timestamp;
        uint256 age = currentTime - _plantedTime;

        // age dan currentTime hilang setelah fungsi selesai
        return age;
    }

    constructor() {
        owner = msg.sender;
        plantCounter = 0;
    }

    function addPlant() public {
        // Local variable
        uint256 newId = plantCounter + 1;

        // Update state variable (biaya gas!)
        plantCounter = newId;
    }
}