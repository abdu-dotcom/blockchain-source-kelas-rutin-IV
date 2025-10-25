// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnAddress {
    address public owner;
    address public gardener;

    constructor() {
        owner = msg.sender;  // msg.sender = alamat wallet Anda
    }

    function setGardener(address _gardener) public {
        gardener = _gardener;
    }
}