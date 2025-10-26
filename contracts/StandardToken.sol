// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title StandardToken
 * @dev Token dengan metadata (name, symbol, decimals)
 */
contract StandardToken {

    // ============ METADATA ============

    /**
     * @dev Nama token (contoh: "Garden Token")
     */
    string public name;

    /**
     * @dev Symbol token (contoh: "GDN")
     */
    string public symbol;

    /**
     * @dev Decimals (biasanya 18, sama seperti ETH)
     *
     * Dengan decimals = 18:
     * 1 token = 1 * 10^18 = 1000000000000000000
     */
    uint8 public decimals;

    // ============ BALANCES ============

    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    // ============ EVENTS ============

    event Transfer(address indexed from, address indexed to, uint256 value);

    // ============ CONSTRUCTOR ============

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        // Initial supply SUDAH dalam wei
        // Contoh: 1 juta token = 1_000_000 * 10^18
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;

        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    // ============ FUNCTIONS ============

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Cannot transfer to zero address");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}