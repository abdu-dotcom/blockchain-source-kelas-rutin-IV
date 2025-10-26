// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LiskGarden {
    // membuat daftar pilihan yang sudah pasti dan memiliki nama.
    // SEED: 0, SPROUT: 1, GROWING: 2, BLOOMING: 3
    enum GrowStage {
        SEED, SPROUT, GROWING, BLOOMING
    }

    // Membuat struct yang akaan digunakan 
    // butuh 8 data
    struct Plant {
        uint256 plantId;                         // nilai uniq tanaman
        address owner;                      // menyimpan address user pemilik
        GrowStage stage;                    // menyimpan stage pertumbuhan tanaman
        uint256 plantedDate;                // tanggal tanaman dibuat
        uint256 lastWatered;                // tanggal terakhir kali tanaman disiram
        uint256 waterLevel;                   // tingkat penyimpanan air tanaman
        bool exists;                        // NA
        bool isDead;                        // menandakan tanaman mati/hidup
    }

    // menyimpan data tanaman atau set data
    mapping(uint256 => Plant) public plants; 
    // Menyimpan addres ke array plant Id (tujuannya track tanaman milik user)
    mapping(address => uint256[]) public userPlants;       

    // untuk menambah tanaman, akan dihitung untuk variable ini sebagai index tanaman
    uint256 public plantCounter;       

    // address public owner, menyimpan owner address didalam dari blockchainnya.
    address public owner;

    // contanta -> value tetap.
    uint256 public constant PLANT_PRICE = 0.001 ether; // biaya tanama tetap sebesar 0.001 ether
    uint256 constant panen = 0.003 ether;   // Biaya tetap panen sebesar 0.003 ether
    uint256 public constant STAGE_DURATION = 1 minutes; // waktu setiap pertumbuhan adalah 1 minutes;
    uint256 public constant WATER_DEPLETION_DURATION = 30 seconds; // lama waktu tanaman akan berkurang takaran airnya
    uint8 public constant WATER_DEPLETION_RATE = 2; // takaran air yang berkurang pada tanaman setiap 30 detik

    // event untuk menampil log saat function dipanggil
    event PlantSeeded(address indexed owner, uint256 indexed plantId); // terjadi saat baru menanamkan tanaman, menampilkan log id tanaman dan pemilik tanaman
    event PlantWatered(uint256 indexed plantId, uint256 newWaterLevel); // terjadi saat user menyiram tanaman, menampilkan log id tanaman dan level penyiraman tanaman
    event PlantHarvested(uint256 indexed plantId, address indexed owner, uint256 reward); // terjadi saat tanaman panen, menampilkan log id tanaman, pemilik tanaman dan reward dari panen
    event StageAdvanced(uint256 indexed plantId, GrowStage newStage); // terjadi saat user melihat proses tanamannya, menampilkan id tanaman dan tanaman sudah proses sampai mana.
    event plantDied(uint256 indexed plantId); // terjadi saat tanaman mati, akan nampilkan id tanaman

    // set nilai awal saat deploy smart coontract
    constructor() {
        owner = msg.sender;
    }

    // fungsi untuk menanam tanaman baru.
    function plantSeed() external payable returns (uint256){
        // 1: cek nominal yg user masukan harus lebih 0.001 eth
        require(msg.value >= PLANT_PRICE, "Minium 0.001 ether");
        // 2: menghitung jumlah  tanaman yg sudah ditanam
        plantCounter += 1;
        // 3: menyiapkan informasi tanaman yg akan ditanaman
        Plant memory newPlant = Plant({
            plantId: plantCounter,
            owner: msg.sender,
            stage: GrowStage.SEED,
            plantedDate: block.timestamp,
            lastWatered: block.timestamp,
            waterLevel: 100,
            exists: true,
            isDead: false
        });
        // 4: menyimpan tanaman yg sudah ditanam di array plants
        plants[plantCounter] = newPlant;
        // 5: menampilkan log bahwa tanaman sudah ditanam
        emit PlantSeeded(newPlant.owner, newPlant.plantId);
        // 6: mengembalikan plantId yang ditanaman
        return plantCounter;
    }

    function calculateWaterLevel(uint256 _plantId) public view returns (uint256){
        // 1: ambil plant dari storage 
        Plant storage myPlant = plants[ _plantId];
        // 2: Jika !exists atau isDead, return 0
        if (myPlant.isDead == true || myPlant.exists == false) {
            return 0;
        }   
        // 3: Hitung lama waktu terakhir kali tanaman disiram
        uint256 timeSinceIntervals = block.timestamp - myPlant.lastWatered;
        
        // 4: Hitung sudah berapa kali air tanaman seharusnya berkurang terakhir kali disiram//
        uint256 depletionIntervals = timeSinceIntervals - WATER_DEPLETION_DURATION;

        // 5: Hitung air yang telah hilang 
        uint256 waterlost = depletionIntervals * WATER_DEPLETION_DURATION;

        // 6: jika air yang hilang lebih besar dari tingkat air, berarti air sudah habis.
        if (waterlost >= myPlant.waterLevel) {
            return 0;
        }

        // 7: kembalikan sisa air yang ada.
        return myPlant.waterLevel - waterlost;
    }

    function updateWaterLevel(uint256 _plantId) internal {
        // 1: ambil plant dari storage 
        Plant storage myPlant = plants[ _plantId];
        // 2. Hitung air yang sekarang menggunakan function calculateWaterLevel
        uint256 currentWaterLevel = calculateWaterLevel(_plantId);
        // 3. Update air tanaman
        myPlant.waterLevel = currentWaterLevel;
        // 4. Update waktu terakhir disiram
        myPlant.lastWatered = block.timestamp; 

        // 5: jika air nya habis dan tanaman masih hidup, ubah jadi mati
        if (myPlant.waterLevel == 0 && myPlant.isDead ==false) {
            myPlant.isDead = true;
        }
    }   

    function waterPlant(uint256 plantId) external {
        // check tanaman yang mau disiram
        Plant memory myPlant = plants[plantId];
        // cek apakah tanaman ada
        require(myPlant.exists == false,"tanaman tidak ditemukan");
        // cek apakah tanaman sudah mati
        require(myPlant.isDead == true, "Tanaman sudah mati");
        
        // set waterlevel = 100 dan jam tanaman disiram
        myPlant.waterLevel = 100;
        myPlant.lastWatered = block.timestamp;
        
        // tampilkan log menandakan tanaman sudah disiram
        emit PlantWatered(plantId,myPlant.waterLevel);

        updatePlantStage(plantId);
    }     

    function updatePlantStage(uint256 plantId) public  {
        // check tanaman yang mau disiram
        Plant memory myPlant = plants[plantId];
         // cek apakah tanaman ada
        require(myPlant.exists == false,"tanaman tidak ditemukan");

        // ubah tingkatan penyiraman tanaman
        updateWaterLevel(plantId);

        // cek apakah tanaman mati 
        if (myPlant.isDead == true) {
            return;
        } 

        GrowStage oldStage = myPlant.stage;
        GrowStage newSatage = oldStage;

        // Hitung berapa lama tanaman terakhir ditanam
        uint256 timeSincePlanted = myPlant.plantedDate - block.timestamp;

        // setiap satu menit tumbuhan bertumbuh
        // 60 detik awal itu proses ditanam
        if (timeSincePlanted >= 0 && timeSincePlanted <= 60) {
            newSatage = GrowStage.SEED;
        } 
        // 120 detik awal itu proses tanaman menyebar
        else if (timeSincePlanted >= 61 && timeSincePlanted <= 120) {
              newSatage = GrowStage.SPROUT;
        } 
        // 160 detik awal itu proses tanaman bertumbuh
        else if (timeSincePlanted >= 121 && timeSincePlanted <= 160) {
            newSatage = GrowStage.GROWING;
        }
        // 210 detik awal itu proses tanaman bertumbuh
        else if (timeSincePlanted >= 161 && timeSincePlanted <= 210) {
            newSatage = GrowStage.BLOOMING;
        } 
        // setelah 210 detik tanaman terus bertumbuh
        else{
            newSatage = GrowStage.BLOOMING;
        }

        // Update stage berdasarkan waktu (3 if statements)
        if (oldStage != newSatage) {
            myPlant.stage = newSatage;

            // Jika stage berubah, emit StageAdvanced
            emit StageAdvanced(plantId, myPlant.stage);
        }
    }

    function harvestPlant(uint256 plantId) external {
        // check tanaman yang mau dipanen
        Plant memory myPlant = plants[plantId];

        // cek apakah tanaman ada
        require(myPlant.exists == false,"tanaman tidak ditemukan");

        // cek owner 
        require(myPlant.owner != owner,"tanaman ini bukan milik kamu");

        // cek tanaman sudah mati
        require(myPlant.isDead == true,"tanaman sudah mati");

        // Call updatePlantStage
        updatePlantStage(plantId);

        // kasih tau tanaman belum mekar
        require(myPlant.stage != GrowStage.BLOOMING, "Tanaman belum mekar");

        // ubah status tanaman sudah tidak tersedia.
        myPlant.exists = false;

        // Menerima uang karena berhasil menanam tanaman
        
    }

    // ============================================
    // HELPER FUNCTIONS (Sudah Lengkap)
    // ============================================

    function getPlant(uint256 plantId) external view returns (Plant memory) {
        Plant memory plant = plants[plantId];
        plant.waterLevel = calculateWaterLevel(plantId);
        return plant;
    }

    function getUserPlants(address user) external view returns (uint256[] memory) {
        return userPlants[user];
    }

    function withdraw() external {
        require(msg.sender == owner, "Bukan owner");
        (bool success, ) = owner.call{value: 0.03 ether}("");
        require(success, "Transfer gagal");
    }

    receive() external payable {}
}