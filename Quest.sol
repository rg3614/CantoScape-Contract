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
        uint256 itemId;
    }

    mapping(uint256 => uint256[]) public drops;
    mapping(uint256 => PlayerQuesting) public questingPlayers;

    mapping(uint256 => QuestDetail) public combatQuests;
    mapping(uint256 => QuestDetail) public fishingQuests;
    mapping(uint256 => QuestDetail) public miningQuests;
    mapping(uint256 => QuestDetail) public smithingQuests;

    constructor(Players _nftCollection) {
        nftCollection = _nftCollection;

        miningQuests[BRONZE] = QuestDetail("BRONZE ORE", 1, 5, BRONZE_ORE);
        miningQuests[IRON] = QuestDetail("IRON ORE", 10, 20, IRON_ORE);
        miningQuests[RUNE] = QuestDetail("RUNE ORE", 40, 200, RUNE_ORE);
        miningQuests[CANTO] = QuestDetail("CANTO ORE", 99, 400, CANTO_ORE);

        fishingQuests[SHRIMP] = QuestDetail("SHRIMP", 1, 5, RAW_SHRIMP);
        fishingQuests[LOBSTER] = QuestDetail("LOBSTER", 40, 200, RAW_LOBSTER);
        fishingQuests[SHARK] = QuestDetail("SHARK", 70, 400, RAW_SHARK);

        smithingQuests[BRONZE] = QuestDetail("BRONZE BAR", 1, 5, BRONZE_BAR);
        smithingQuests[IRON] = QuestDetail("IRON BAR", 10, 20, IRON_BAR);
        smithingQuests[RUNE] = QuestDetail("RUNE BAR", 40, 200, RUNE_BAR);
        smithingQuests[CANTO] = QuestDetail("CANTO BAR", 99, 400, CANTO_BAR);

        combatQuests[CHICKEN] = QuestDetail("CHICKEN", 1, 5, 0);
        combatQuests[GOBLIN] = QuestDetail("GOBLIN", 5, 25, 0);
        combatQuests[WARRIOR] = QuestDetail("WARRIOR", 10, 50, 0);
        combatQuests[BARBARIAN] = QuestDetail("BARBARIAN", 20, 75, 0);
        combatQuests[HILL_GIANT] = QuestDetail("HILL_GIANT", 30, 100, 0);
        combatQuests[MOSS_GIANT] = QuestDetail("MOSS_GIANT", 40, 125, 0);
        combatQuests[LESSER_DEMON] = QuestDetail("LESSER_DEMON", 50, 200, 0);
        combatQuests[GREATER_DEMON] = QuestDetail("GREATER_DEMON", 60, 400, 0);
    }

    uint256 rewardsMultipler = 1;

    function setRewards(uint256 _rewardsMultipler) public onlyOwner {
        rewardsMultipler = _rewardsMultipler;
    }

    function quest(uint256 _tokenId, uint256 _questType, uint256 _questDetail) external  {
        require(nftCollection.ownerOf(_tokenId) == msg.sender, "Can't stake tokens you don't own!");

        checkLevel(_tokenId, _questType, _questDetail);

        PlayerQuesting storage playerQuest = questingPlayers[_tokenId];
        playerQuest.id = _tokenId;
        playerQuest.isQuesting = true;
        playerQuest.time = block.timestamp;
        playerQuest.owner = msg.sender;
        playerQuest.questType = _questType;
        playerQuest.questDetail = _questDetail;

        nftCollection.transferFrom(msg.sender, address(this), _tokenId);
    }

    function craft(uint256 _playerId, uint256 _itemId, uint256 _amount) external {
        uint256 xp = _amount * smithingQuests[_itemId].xp;
        nftCollection.craft(_playerId, _itemId, _amount, xp);
    }

    function checkLevel(uint256 _tokenId, uint256 _questType, uint256 _questDetail) internal view {
        if (_questType == FISHING) {
            uint256 lvl = fishingQuests[_questDetail].lvl;
            uint256 fishingLevel = nftCollection.getFishingLevel(_tokenId);
            require (fishingLevel >= lvl, "Level too low");
        }
        if (_questType == MINING) {
            // Make function for get mining level
            uint256 lvl = miningQuests[_questDetail].lvl;
            uint256 fishingLevel = nftCollection.getMiningLevel(_tokenId);
            require (fishingLevel >= lvl, "Level too low");
        }
        if (_questType == COMBAT) {
            // Make getter
            uint256 lvl = combatQuests[_questDetail].lvl;
            uint256 fishingLevel = nftCollection.getFishingLevel(_tokenId);
            require (fishingLevel >= lvl, "Level too low");
        }
        if (_questType == SMITHING) {
            // Make getter
            uint256 lvl = smithingQuests[_questDetail].lvl;
            uint256 fishingLevel = nftCollection.getSmithingLevel(_tokenId);
            require (fishingLevel >= lvl, "Level too low");
        }
    }

    function withdraw(uint256[] calldata _tokenIds) external nonReentrant {
        uint256 lenToWithdraw = _tokenIds.length;
        for (uint256 i; i < lenToWithdraw; ++i) {
            PlayerQuesting storage playerQuest = questingPlayers[_tokenIds[i]];
            QuestDetail storage questDetail = fishingQuests[playerQuest.questDetail];

            if (playerQuest.questType == MINING) {
                questDetail = miningQuests[playerQuest.questDetail];
            } else if (playerQuest.questType == COMBAT) {
                questDetail = combatQuests[playerQuest.questDetail];
            }

            require(questingPlayers[_tokenIds[i]].owner == msg.sender);

            // Calc amount, rewards
            uint256 xpEarned;
            uint256 itemAmount;
            uint256 itemId = questDetail.itemId;

            (xpEarned, itemAmount) = getRewards(_tokenIds[i]);

            nftCollection.rewards(_tokenIds[i], playerQuest.owner, playerQuest.questType, xpEarned*questDetail.xp , itemId, itemAmount);

            playerQuest.isQuesting = false;

            nftCollection.transferFrom(address(this), msg.sender, _tokenIds[i]);
        }
    }

    uint256 xpDenom = 150;

    function getRewards(uint256 _playerId) internal view returns (uint256 xp, uint256 amount) {
        PlayerQuesting storage playerQuest = questingPlayers[_playerId];
        uint256 timeDifference = (block.timestamp - playerQuest.time) * rewardsMultipler;
        amount = timeDifference / xpDenom;
        return (amount, amount);
    }

}