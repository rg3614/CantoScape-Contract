// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts@4.8.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.2/utils/Counters.sol";

import "./CantoScapeLib.sol";
import "./Items.sol";

contract Players is ERC721, ERC721Burnable, Ownable, ERC721Holder {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    CantoScapeItems public immutable items;
    
    constructor(
        CantoScapeItems itemsContractAddress
    ) ERC721("CantoScapePlayers", "CSP") {
        items = itemsContractAddress;
        setXp();
    }
    
    address questContract;

    // Remove Melee switch to Attack/Str/Def/HP = Combat Level
    struct Player {
        uint8 fishingLevel;
        uint8 cookingLevel;
        uint8 miningLevel;
        uint8 smithingLevel;
        uint8 meleeLevel;
        uint8 hitpointsLevel;
        uint256 currentFishingXp;
        uint256 currentCookingXp;
        uint256 currentMiningXp;
        uint256 currentSmithingXp;
        uint256 currentMeleeXp;
        uint256 currentHitpointsXp;
    }

    // 11 len
    struct PlayerEquipment {
        uint256 head;
        uint256 neck;
        uint256 back;
        uint256 ammo;
        uint256 leftHand;
        uint256 rightHand;
        uint256 chest;
        uint256 legs;
        uint256 gloves;
        uint256 boots;
        uint256 ring;
    }

    Player[] players;
    PlayerEquipment[] playerEquipments;

    mapping(uint256 => uint256) public xpForLevel;

    modifier onlyOwnerOf(uint256 _playerId) {
        require(ownerOf(_playerId) == msg.sender, "Must be owner of player");
        _;
    }

    function setXp() internal {
        uint256 i = 2;
        uint256 xp = 100;
        xpForLevel[1] = xp;
        for (i; i < 100; ++i) {
            xpForLevel[i] = xp + xp / 10;
            xp = xp + xp / 10;
        }
    }

    // Attack, Deffence
    function getCombatBonus(uint256 _playerId) view public returns(uint256[2] memory bonuses) {
        PlayerEquipment storage playerEquipment = playerEquipments[_playerId];
        uint256 a;
        uint256 d;
        uint256 attackBonus;
        uint256 defenseBonus;
        (a,d) = readCombatBonuses(playerEquipment.head);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.neck);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.back);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.ammo);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.leftHand);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.rightHand);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.chest);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.legs);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.gloves);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.boots);
        attackBonus += a;
        defenseBonus += d;
        (a,d) = readCombatBonuses(playerEquipment.ring);
        attackBonus += a;
        defenseBonus += d;
        return [attackBonus, defenseBonus];
    }

    function readCombatBonuses(uint256 _id) view internal returns (uint256 attack, uint256 defense) {
        return items.EquipmentBonuses(_id);
    }

    // TODO: Transfer items in/out
    function equipItems(uint256 _playerId, uint256[] memory _items) public {
        // Require length _items
        uint256 head = _items[0];
        uint256 neck = _items[1];
        uint256 back = _items[2];
        uint256 ammo = _items[3];
        uint256 leftHand = _items[4];
        uint256 rightHand = _items[5];
        uint256 chest = _items[6];
        uint256 legs = _items[7];
        uint256 gloves = _items[8];
        uint256 boots = _items[9];
        uint256 ring = _items[10];

        PlayerEquipment storage playerEquipment = playerEquipments[_playerId];
        // 1000 = Keep current equipment
        // Require certain level for equipment
        if (head != 1000) {
            playerEquipment.head = head;
        }
        if (back != 1000) {
            playerEquipment.back = back;
        }
        if (neck != 1000) {
            playerEquipment.neck = back;
        }
        if (ammo != 1000) {
            playerEquipment.ammo = ammo;
        }
        if (leftHand != 1000) {
            playerEquipment.leftHand = leftHand;
        }
        if (rightHand != 1000) {
            playerEquipment.rightHand = rightHand;
        }
        if (chest != 1000) {
            playerEquipment.chest = chest;
        }
        if (legs != 1000) {
            playerEquipment.legs = legs;
        }
        if (gloves != 1000) {
            playerEquipment.gloves = gloves;
        }
        if (boots != 1000) {
            playerEquipment.boots = boots;
        }
        if (ring != 1000) {
            playerEquipment.ring = ring;
        }
    }

    function getFishingXp(uint256 _playerId) public view returns (uint256) {
        Player storage player = players[_playerId];
        return player.currentFishingXp;
    }

    function getFishingLevel(uint256 _playerId) public view returns (uint256) {
        Player storage player = players[_playerId];
        return player.fishingLevel;
    }
    function getMiningLevel(uint256 _playerId) public view returns (uint256) {
        Player storage player = players[_playerId];
        return player.miningLevel;
    }
    function getSmithingLevel(uint256 _playerId) public view returns (uint256) {
        Player storage player = players[_playerId];
        return player.smithingLevel;
    }

    function setQuestContract(address _questContract) public onlyOwner {
        questContract = _questContract;
    }

    // Set cap at 99
    function levelUp(uint256 _playerId, uint256 _questType) internal {
        if (_questType == FISHING) {
            Player storage player = players[_playerId];
            player.currentFishingXp = player.currentFishingXp - xpForLevel[player.fishingLevel];
            player.fishingLevel += 1;
        } else if (_questType == MINING) {
            Player storage player = players[_playerId];
            player.currentMiningXp = player.currentMiningXp - xpForLevel[player.miningLevel];
            player.miningLevel += 1;
        }
    }

    function rewards(uint256 _playerId, address _playerAddress, uint256 _questType, uint256 _xp, uint256 _itemId, uint256 _amount) public {
        require (msg.sender == questContract, "403");

        Player storage player = players[_playerId];

        if (_questType == FISHING) {
            player.currentFishingXp += _xp;
            items.mint(_playerAddress, _itemId, _amount, "");
            if (player.currentFishingXp >= xpForLevel[player.fishingLevel]) {
                bool keepLvling = true;
                while(keepLvling) {
                    if (player.fishingLevel > 98) {
                        keepLvling = false;
                    } else if (player.currentFishingXp >= xpForLevel[player.fishingLevel]) {
                        levelUp(_playerId, _questType);
                    } else {
                        keepLvling = false;
                    }
                }
            }
        } else if (_questType == MINING) {
            player.currentMiningXp += _xp;
            items.mint(_playerAddress, _itemId, _amount, "");
            if (player.currentMiningXp >= xpForLevel[player.miningLevel]) {
                bool keepLvling = true;
                while(keepLvling) {
                    if (player.miningLevel > 98) {
                        keepLvling = false;
                    } else if (player.currentMiningXp >= xpForLevel[player.miningLevel]) {
                        levelUp(_playerId, _questType);
                    } else {
                        keepLvling = false;
                    }
                }
            }
        }
    }

    function craft(uint256 _playerId, uint256 _itemId, uint256 _amount, uint256 xp, address _sender) public {
        require (msg.sender == questContract, "403");
        // XP added after second require
        Player storage player = players[_playerId];
        player.currentSmithingXp += xp;
        if (player.currentSmithingXp >= xpForLevel[player.smithingLevel]) {
            bool keepLvling = true;
            while(keepLvling) {
                if (player.smithingLevel > 98) {
                    keepLvling = false;
                } else if (player.currentSmithingXp >= xpForLevel[player.smithingLevel]) {
                    levelUp(_playerId, SMITHING);
                } else {
                    keepLvling = false;
                }
            }
        }
        uint256 itemReq;
        uint256 amount;

        (, itemReq, amount) = items.CraftingRecipes(_itemId);
        require(items.balanceOf(_sender, itemReq) > amount * _amount, "Missing Required materials");
        items.burn(_sender, itemReq, amount * _amount);
        items.mint(_sender, _itemId, amount * _amount, "");
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmQnfPjmxYsv8fkEWmav7GmyRaPmnrs9AeW2Jw5KL2oW1o/";
    }

    function createPlayer() public {
        
        uint256 tokenId = _tokenIdCounter.current();
        Player memory player;
        player.fishingLevel = 1;
        player.cookingLevel = 1;
        player.miningLevel = 1;
        player.smithingLevel = 1;
        player.meleeLevel = 1;
        player.hitpointsLevel = 10;
        player.currentFishingXp = 0;
        player.currentCookingXp = 0;
        player.currentMiningXp = 0;
        player.currentSmithingXp = 0;
        player.currentMeleeXp = 0;
        player.currentHitpointsXp = 0;
        players.push(player);

        PlayerEquipment memory playerEquipment;
        playerEquipment.head = 0;
        playerEquipment.neck = 0;
        playerEquipment.back = 0;
        playerEquipment.ammo = 0;
        playerEquipment.leftHand = 0;
        playerEquipment.rightHand = 0;
        playerEquipment.chest = 0;
        playerEquipment.legs = 0;
        playerEquipment.gloves = 0;
        playerEquipment.boots = 0;
        playerEquipment.ring = 0;

        playerEquipments.push(playerEquipment);

        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        setApprovalForAll(address(this), true);
    }
}
