// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Combat {
    constructor() {
        monsters[GOBLIN] = monster("GOBLIN", 3, 20);
    }

  