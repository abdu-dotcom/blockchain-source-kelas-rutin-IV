// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title BasicToken
 * @dev Token paling sederhana - hanya transfer
 */
contract BasicToken {

    // ============ STATE VARIABLES ============

    /**
     * @dev Mapping dari address ke balance
     * Contoh: balances[0x123...] = 1000
     */
    mapping(address => uint256) public balances;

    /**
     * @dev Total supply token
     */
    uint256 public totalSupply;

    // ============ EVENTS ============

    /**
     * @dev Event ketika transfer terjadi
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    // ============ CONSTRUCTOR ============

    /**
     * @dev Mint initial supply ke creator
     */
    constructor(uint256 _initialSupply) {
        // Semua token ke creator contract
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;

        // Emit transfer dari address(0) = minting
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    // ============ PUBLIC FUNCTIONS ============

    /**
     * @dev Transfer token ke address lain
     * @param _to Recipient address
     * @param _value Jumlah token
     * @return success True jika berhasil
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // 1. Validasi: punya cukup balance?
        require(balances[msg.sender] >= _value, "Insufficient balance");

        // 2. Validasi: recipient valid?
        require(_to != address(0), "Cannot transfer to zero address");

        // 3. Update balances
        balances[msg.sender] -= _value;  // Kurangi sender
        balances[_to] += _value;          // Tambah recipient

        // 4. Emit event
        emit Transfer(msg.sender, _to, _value);

        // 5. Return success
        return true;
    }

    /**
     * @dev Get balance of address
     * @param _owner Address to check
     * @return balance Token balance
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}