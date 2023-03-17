// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts@4.8.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.2/utils/Counters.sol";

import "./Items.sol";

contract Players is ERC721, ERC721Burnable, Ownable, ERC721Holder {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    CantoScapeItems public immutable items;
    
    constructor(
        CantoScapeItems itemsContractAddress
    ) ERC721("CantoScapePlayers", "CSP") {
        items = itemsContractAddress;
    }
    
    address questContract;

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
        uint256 fishingXpForLevel;
        uint256 cookingXpForLevel;
        uint256 miningXpForLevel;
        uint256 smithingXpForLevel;
        uint256 meleeXpForLevel;
        uint256 HitpointsXpForLevel;
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

    uint256 public constant BRONZE_PICKAXE = 1;
    uint256 public constant IRON_PICKAXE = 2;
    uint256 public constant RUNE_PICKAXE = 3;

    uint256 public constant FISHING_ROD = 4;

    uint256 public constant BRONZE_LONGSWORD = 5;
    uint256 public constant IRON_LONGSWORD = 6;
    uint256 public constant RUNE_LONGSWORD = 7;

    uint256 public constant BRONZE_FULL_HELM = 8;
    uint256 public constant BRONZE_PLATEBODY = 9;
    uint256 public constant BRONZE_PLATELEGS = 10;

    uint256 public constant RAW_SHRIMP = 11;
    uint256 public constant RAW_LOBSTER = 12;
    uint256 public constant RAW_SHARK = 13;

    uint256 public constant GOLD = 14;

    uint256 public constant TIN_ORE = 15;
    uint256 public constant COPPER_ORE = 16;
    uint256 public constant IRON_ORE = 17;
    uint256 public constant RUNE_ORE = 18;
    uint256 public constant CANTO_ORE = 19;

    uint256 public constant BRONZE_BAR = 20;

    uint256 rewardsMultipler = 1;

    Player[] players;
    PlayerEquipment[] playerEquipments;

    modifier onlyOwnerOf(uint256 _playerId) {
        require(ownerOf(_playerId) == msg.sender, "Must be owner of player");
        _;
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

    function setQuestContract(address _questContract) public onlyOwner {
        questContract = _questContract;
    }

    function setRewards(uint256 _rewardsMultipler) public onlyOwner {
        rewardsMultipler = _rewardsMultipler;
    }

    function levelUp(uint256 _playerId, uint256 _questType) internal {
        if (_questType == 11 || _questType == 12) {
            Player storage player = players[_playerId];
            player.fishingLevel += 1;
            player.currentFishingXp = player.currentFishingXp - player.fishingXpForLevel;
            player.fishingXpForLevel = uint256(player.fishingLevel) * 100;
        } else if (_questType == 15 || _questType == 16 || _questType == 17) {
            Player storage player = players[_playerId];
            player.miningLevel += 1;
            player.currentMiningXp = player.currentMiningXp - player.miningXpForLevel;
            player.miningXpForLevel = uint256(player.miningLevel) * 100;
        }
    }

    function rewards(uint256 _playerId, uint256 _time, address _playerAddress, uint256 _questType) public {
        require (msg.sender == questContract, "403");
        Player storage player = players[_playerId];
        uint256 timeDifference = (block.timestamp - _time) * rewardsMultipler;

        if (_questType == 11 || _questType == 12) {
            player.currentFishingXp += timeDifference;
            // Add probability for mint
            items.mint(_playerAddress, _questType, timeDifference, "");
            if (player.currentFishingXp >= player.fishingXpForLevel) {
                while(player.currentFishingXp >= player.fishingXpForLevel) {
                    levelUp(_playerId, _questType);
                }
            }
        } else if (_questType == 15 || _questType == 16 || _questType == 17) {
            player.currentMiningXp += timeDifference;
            // Add probability for mint
            items.mint(_playerAddress, _questType, timeDifference, "");
            if (player.currentMiningXp >= player.miningXpForLevel) {
                while(player.currentMiningXp >= player.miningXpForLevel) {
                    levelUp(_playerId, _questType);
                }
            }
        }
    }

    // TODO: Smithing XP
    function craftItems(uint256 _itemId, uint256 _amount)  public {
        if (_itemId == BRONZE_FULL_HELM) {
            require(items.balanceOf(msg.sender, BRONZE_BAR) >= 2 * _amount, "Missing Required materials");
            // Burn here
         //   safeTransferFrom(msg.sender, address(this), BRONZE_BAR, 2 * _amount, "");
            items.burn(msg.sender, BRONZE_BAR, 2 * _amount);
            items.mint(msg.sender, BRONZE_FULL_HELM, _amount, "");
        }        
    }

    // TODO: Smithing XP
    function smithOre(uint256 _itemId, uint256 _amount) public {
        if (_itemId == BRONZE_BAR) {
            require(items.balanceOf(msg.sender, TIN_ORE) > _amount && items.balanceOf(msg.sender, COPPER_ORE) > _amount, "Missing Required materials");
            // BURN
         //   safeTransferFrom(msg.sender, address(this), TIN_ORE, _amount, "");
            items.burn(msg.sender, TIN_ORE, _amount);
            items.burn(msg.sender, COPPER_ORE, _amount);
          //  safeTransferFrom(msg.sender, address(this), COPPER_ORE, _amount, "");
            items.mint(msg.sender, BRONZE_BAR, _amount, "");
        }
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
        player.fishingXpForLevel = 100;
        player.cookingXpForLevel = 100;
        player.miningXpForLevel = 100;
        player.smithingXpForLevel = 100;
        player.meleeXpForLevel = 100;
        player.HitpointsXpForLevel = 100;
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
