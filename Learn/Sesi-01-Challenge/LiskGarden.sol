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
    uint256 public constant PLANT_PRICE = 0.00001 ether; // biaya tanama tetap sebesar 0.001 ether
    uint256 constant panen = 0.00003 ether;   // Biaya tetap panen sebesar 0.003 ether
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

     // Cek saldo contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // fungsi untuk menanam tanaman baru.
    // payable untuk mengirim uang ke address utama kontrak.
    function plantSeed() external payable returns (uint256){
        // 1: cek nominal yg user masukan harus lebih 0.001 eth
        require(msg.value >= PLANT_PRICE, "Minium 0.00001 ether");
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
        // 5. Push plantId ke userPlants
        userPlants[msg.sender].push(newPlant.plantId);
        // 6: menampilkan log bahwa tanaman sudah ditanam
        emit PlantSeeded(newPlant.owner, newPlant.plantId);
        // 6: mengembalikan plantId yang ditanaman
        return plantCounter;
    }

    function calculateWaterLevel(uint256 _plantId) public view returns (uint256){
        // 1: ambil plant dari storage 
        Plant memory myPlant = plants[ _plantId];
        // 2: Jika !exists atau isDead, return 0
        if (myPlant.isDead == true || myPlant.exists == false) {
            return 0;
        }   

        // waktu mundur? jangan kurangi
        if (block.timestamp <= myPlant.lastWatered) return myPlant.waterLevel;

        uint256 elapsed = block.timestamp - myPlant.lastWatered;             // ✅ urutan benar
        if (elapsed < WATER_DEPLETION_DURATION) return myPlant.waterLevel;   // ✅ belum 1 interval

        uint256 intervals = elapsed / WATER_DEPLETION_DURATION;        // ✅ jangan minus
        uint256 lost = intervals * WATER_DEPLETION_RATE;

        // ✅ clamp agar tak underflow
        return (myPlant.waterLevel > lost) ? (myPlant.waterLevel - lost) : 0;
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
        Plant storage myPlant = plants[plantId];
        // cek apakah tanaman ada
        require(myPlant.exists == true,"tanaman tidak ditemukan");
        // cek apakah tanaman sudah mati
        require(myPlant.isDead == false, "Tanaman sudah mati");
        
        // set waterlevel = 100 dan jam tanaman disiram
        myPlant.waterLevel = 100;
        myPlant.lastWatered = block.timestamp;
        
        // tampilkan log menandakan tanaman sudah disiram
        emit PlantWatered(plantId,myPlant.waterLevel);

        updatePlantStage(plantId);
    }     

    function updatePlantStage(uint256 plantId) public  {
        // check tanaman yang mau disiram
        Plant storage myPlant = plants[plantId];
         // cek apakah tanaman ada
        require(myPlant.exists == true,"tanaman tidak ditemukan");

        // ubah tingkatan penyiraman tanaman
        updateWaterLevel(plantId);

        // cek apakah tanaman mati 
        if (myPlant.isDead == true) {
            return;
        } 

        GrowStage oldStage = myPlant.stage;
        GrowStage newSatage = oldStage;

        // Hitung berapa lama tanaman terakhir ditanam
        uint256 timeSincePlanted = block.timestamp - myPlant.plantedDate;

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
        Plant storage myPlant = plants[plantId];

        // cek apakah tanaman ada
        require(myPlant.exists == true,"tanaman tidak ditemukan");

        // cek owner 
        require(msg.sender == myPlant.owner,"tanaman ini bukan milik kamu");

        // cek tanaman sudah mati
        require(myPlant.isDead == false,"tanaman sudah mati");

        // Call updatePlantStage
        updatePlantStage(plantId);

        // kasih tau tanaman belum mekar
        require(myPlant.stage == GrowStage.BLOOMING, "Tanaman belum mekar");

        // ubah status tanaman sudah tidak tersedia.
        myPlant.exists = false;

        // 7. Emit PlantHarvested
        emit PlantHarvested(plantId, msg.sender, panen);

        // 8. Transfer reward
        require(address(this).balance >= panen, "Saldo kontrak tidak cukup");
        (bool success, ) = payable(msg.sender).call{value: panen}("");

         // 9. require success
        require(success, "Transfer reward gagal");

    }

    // ============================================
    // HELPER FUNCTIONS (Sudah Lengkap)
    // ============================================

    function getPlant(uint256 plantId) external view returns (Plant memory) {
        Plant memory myPlant = plants[plantId];
        myPlant.waterLevel = calculateWaterLevel(plantId);

        if (myPlant.waterLevel == 0) {
            myPlant.isDead = true;
        }
        return myPlant;
    }

    function getUserPlants(address user) external view returns (uint256[] memory) {
        return userPlants[user];
    }

    function withdraw() external {
        require(msg.sender == owner, "Bukan owner");
        (bool success, ) = owner.call{value: 0.0003 ether}("");
        require(success, "Transfer gagal");
    }

    receive() external payable {}
}