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

    struct Player {
        uint8 fishingLevel;
        uint8 cookingLevel;
        uint8 miningLevel;
        uint8 smithingLevel;
        uint8 attackLevel;
        uint8 strengthLevel;
        uint8 defenseLevel;
        uint8 hitpointsLevel;
        uint256 currentFishingXp;
        uint256 currentCookingXp;
        uint256 currentMiningXp;
        uint256 currentSmithingXp;
        uint256 currentAttackXp;
        uint256 currentStrengthXp;
        uint256 currentDefenseXp;
        uint256 currentHitpointsXp;
    }

    // 11 len
    struct PlayerEquipment {
        uint256[11] equipment;
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
    function getCombatBonus(uint256 _playerId) view public returns(uint256 attackBonus, uint256 defStrengthBonus) {
        PlayerEquipment storage playerEquipment = playerEquipments[_playerId];
        uint256 a;
        uint256 s;
        uint256 d;

        for (uint i = 0; i < 11; i++) {
            (a, s, , d,) = readCombatBonuses(getEquipment(playerEquipment, i));
            attackBonus += a + s;
            defStrengthBonus += d;
        }

        return (attackBonus, defStrengthBonus);
    }

    function readCombatBonuses(uint256 _id) view internal returns (uint256 attAttackBonus,uint256 attStrengthBonus,uint256 defAttackBonus,uint256 defStrengthBonus,uint256 defenseBonus) {
        return items.EquipmentBonuses(_id);
    }
    function getEquipment(PlayerEquipment storage playerEquipment, uint i) internal view returns(uint256) {
        return playerEquipment.equipment[i];
    }

    // TODO: Transfer items in/out
    function equipItems(uint256 _playerId, uint256[11] memory _items) public {
        PlayerEquipment storage playerEquipment = playerEquipments[_playerId];
        for (uint i = 0; i < 11; i++) {
            if (_items[i] != 1000) {
               playerEquipment.equipment[i] = _items[i];
            }
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

    function getCombatStats(uint256 _playerId) public view returns (uint256,uint256,uint256) {
        Player storage player = players[_playerId];
        return (player.attackLevel,player.strengthLevel,player.defenseLevel);
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
        } else if (_questType == SMITHING) {
            Player storage player = players[_playerId];
            player.currentSmithingXp = player.currentSmithingXp - xpForLevel[player.smithingLevel];
            player.smithingLevel += 1;
        }
    }

    function rewards(uint256 _playerId, uint256 _questType, uint256 _xp) public {
        require (msg.sender == questContract, "403");

        Player storage player = players[_playerId];

        if (_questType == FISHING) {
            player.currentFishingXp += _xp;
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
        } else if (_questType == SMITHING) {    
            player.currentSmithingXp += _xp;
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
        } 
    }


    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmQnfPjmxYsv8fkEWmav7GmyRaPmnrs9AeW2Jw5KL2oW1o/";
    }

    function createPlayer() public {
        
        uint256 tokenId = _tokenIdCounter.current();
        players.push(Player({
            fishingLevel: 1,
            cookingLevel: 1,
            miningLevel: 1,
            smithingLevel: 1,
            strengthLevel: 50,
            attackLevel: 1,
            defenseLevel: 1,
            hitpointsLevel: 10,
            currentFishingXp: 0,
            currentCookingXp: 0,
            currentMiningXp: 0,
            currentSmithingXp: 0,
            currentAttackXp: 0,
            currentStrengthXp: 0,
            currentDefenseXp: 0,
            currentHitpointsXp: 0
        }));

        PlayerEquipment memory newEquipment = PlayerEquipment({
            equipment: [uint256(1000), 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
        });

        playerEquipments.push(newEquipment);

        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        setApprovalForAll(address(this), true);
    }
}
