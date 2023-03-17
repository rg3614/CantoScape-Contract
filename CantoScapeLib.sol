// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library cantoScapeLib {
    // Quest Types
    uint256 constant FISHING = 1;
    uint256 constant MINING = 2;
    uint256 constant COMBAT = 3;

    // Fishing Types
    uint256 constant SHRIMP = 1;
    uint256 constant LOBSTER = 2;
    uint256 constant SHARK = 3;

    // Mining Types
    uint256 constant COPPER = 1;
    uint256 constant TIN = 2;
    uint256 constant IRON = 3;
    uint256 constant RUNE = 4;
    uint256 constant CANTO = 5;

    // NPC Types
    uint256 constant CHICKEN = 1;
    uint256 constant GOBLIN = 2;
    uint256 constant WARRIOR = 3;
    uint256 constant BARBARIAN = 4;
    uint256 constant HILL_GIANT = 5;
    uint256 constant MOSS_GIANT = 6;
    uint256 constant LESSER_DEMON = 7;
    uint256 constant GREATER_DEMON = 8;
}