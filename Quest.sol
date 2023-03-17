// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "Players.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./CantoScapeLib.sol";

contract Quest is Ownable, ReentrancyGuard {
    Players public immutable nftCollection;

    struct PlayerQuesting {
        uint256 id;
        bool isQuesting;
        uint256 time;
        uint256 questType;
        uint256 questDetail;
        address owner;
    }

    struct QuestDetail {
        string name;
        uint256 lvl;
        uint256 xp;
    }

    mapping(uint256 => uint256[]) public drops;
    mapping(uint256 => PlayerQuesting) public questingPlayers;

    mapping(uint256 => QuestDetail) public combatQuests;
    mapping(uint256 => QuestDetail) public fishingQuests;
    mapping(uint256 => QuestDetail) public miningQuests;

    constructor(Players _nftCollection) {
        nftCollection = _nftCollection;

        miningQuests[COPPER] = QuestDetail("COPPER", 1, 5);
        miningQuests[TIN] = QuestDetail("TIN", 1, 5);
        miningQuests[IRON] = QuestDetail("IRON", 10, 20);
        miningQuests[RUNE] = QuestDetail("RUNE", 40, 200);
        miningQuests[CANTO] = QuestDetail("CANTO", 99, 400);

        fishingQuests[SHRIMP] = QuestDetail("SHRIMP", 1, 5);
        fishingQuests[LOBSTER] = QuestDetail("LOBSTER", 40, 200);
        fishingQuests[SHARK] = QuestDetail("SHARK", 70, 400);

        combatQuests[CHICKEN] = QuestDetail("CHICKEN", 1, 5);
        combatQuests[GOBLIN] = QuestDetail("GOBLIN", 5, 25);
        combatQuests[WARRIOR] = QuestDetail("WARRIOR", 10, 50);
        combatQuests[BARBARIAN] = QuestDetail("BARBARIAN", 20, 75);
        combatQuests[HILL_GIANT] = QuestDetail("HILL_GIANT", 30, 100);
        combatQuests[MOSS_GIANT] = QuestDetail("MOSS_GIANT", 40, 125);
        combatQuests[LESSER_DEMON] = QuestDetail("LESSER_DEMON", 50, 200);
        combatQuests[GREATER_DEMON] = QuestDetail("GREATER_DEMON", 60, 400);
    }

    function quest(uint256 _tokenId, uint256 _questType, uint256 _questDetail) external  {
        require(nftCollection.ownerOf(_tokenId) == msg.sender, "Can't stake tokens you don't own!");

        checkLevel(_tokenId, _questType);
        PlayerQuesting storage playerQuest = questingPlayers[_tokenId];
        playerQuest.id = _tokenId;
        playerQuest.isQuesting = true;
        playerQuest.time = block.timestamp;
        playerQuest.owner = msg.sender;
        playerQuest.questType = _questType;
        playerQuest.questDetail = _questDetail;
        nftCollection.transferFrom(msg.sender, address(this), _tokenId);
    }

    function checkLevel(uint256 _tokenId, uint256 _questType) internal view {
        if (_questType == 12) {
            uint256 fishingLevel = nftCollection.getFishingLevel(_tokenId);
            require (fishingLevel > 20, "Level too low");
        }
        if (_questType == 13) {
            uint256 fishingLevel = nftCollection.getFishingLevel(_tokenId);
            require (fishingLevel > 40, "Level too low");
        }
    }

    function withdraw(uint256[] calldata _tokenIds) external nonReentrant {
        uint256 lenToWithdraw = _tokenIds.length;
        for (uint256 i; i < lenToWithdraw; ++i) {
            PlayerQuesting storage playerQuest = questingPlayers[_tokenIds[i]];
            require(questingPlayers[_tokenIds[i]].owner == msg.sender);


            // Change to just sending XP and skill
            nftCollection.rewards(_tokenIds[i],playerQuest.time, playerQuest.owner, playerQuest.questType);

            playerQuest.isQuesting = false;

            nftCollection.transferFrom(address(this), msg.sender, _tokenIds[i]);
        }
    }

}