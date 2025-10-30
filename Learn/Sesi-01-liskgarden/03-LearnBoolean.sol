// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnBoolean {
    bool public isAlive;
    bool public isBlooming;

    constructor() {
        isAlive = true;
        isBlooming = false;
    }

    function changeStatus(bool _status) public {
        isAlive = _status;
    }

    function bloom() public {
        isBlooming = true;
    }
}