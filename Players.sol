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

    struct Player {
        uint8 fishingLevel;
        uint8 cookingLevel;
        uint8 miningLevel;
        uint8 smithingLevel;
        uint8 meleeLevel;
        uint8 hitpointsLevel;
        uint8 stamina;
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

    struct PlayerQuesting {
        bool isQuesting;
        uint256 time;
        uint256 typeQuest;
        address owner;
    }

    mapping(uint256 => PlayerQuesting) public playerQuesting;

    Player[] players;

    modifier onlyOwnerOf(uint256 _playerId) {
        require(ownerOf(_playerId) == msg.sender, "Must be owner of player");
        _;
    }

    function getFishingXp(uint256 _playerId) public view returns (uint256) {
        Player storage player = players[_playerId];
        return player.currentFishingXp;
    }

    function getFishingLevel(uint256 _playerId) public view returns (uint256) {
        Player storage player = players[_playerId];
        return player.fishingLevel;
    }

    // function setXp(uint256 _playerId, string memory _skill, uint256 _xpGained) internal {
    //     Player storage player = players[_playerId];
    //         player.currentFishingXp += _xpGained;
    // }

    function levelUp(uint256 _playerId) internal {
        Player storage player = players[_playerId];
        player.fishingLevel += 1;
        player.currentFishingXp = player.currentFishingXp - player.fishingXpForLevel;
        player.fishingXpForLevel = uint256(player.fishingLevel) * 100;
    }

    // function quest(uint256 _playerId, string memory _skill, string memory _type) public onlyOwnerOf(_playerId) {
    //     Player storage player = players[_playerId];
    //     if (player.currentFishingXp >= player.fishingXpForLevel) {
    //         levelUp(_playerId, _skill);
    //     }

    //     if (keccak256(bytes(_skill)) == keccak256(bytes("fishing"))) {
    //         if (keccak256(bytes(_skill)) == keccak256(bytes("shrimp"))) {
    //             items.mint(msg.sender, 11, 1, "");
    //             setXp(_playerId, _skill, 25);
    //         }
    //     }
    // }

    function quest(uint256 _playerId, uint256 _questType) public onlyOwnerOf(_playerId){
       // Player storage player = players[_playerId];
        safeTransferFrom(msg.sender, address(this), _playerId);
        playerQuesting[_playerId].isQuesting = true;
        playerQuesting[_playerId].typeQuest = _questType;
        playerQuesting[_playerId].time = block.timestamp;
        playerQuesting[_playerId].owner = msg.sender;
    }

    function withdraw(uint256 _playerId) public {
        require(
            playerQuesting[_playerId].owner == msg.sender, "Not owner"
        );
        require(
            playerQuesting[_playerId].isQuesting, "Not Questing"
        );
        rewards(_playerId);
        approve(msg.sender, _playerId);
        safeTransferFrom(address(this), msg.sender, _playerId);
        
        playerQuesting[_playerId].isQuesting = false;
        playerQuesting[_playerId].typeQuest = 0;
        playerQuesting[_playerId].time = block.timestamp;
    }

    function rewards(uint256 _playerId) internal {
        Player storage player = players[_playerId];
        uint256 timeDifference = block.timestamp - playerQuesting[_playerId].time;
        items.mint(msg.sender, 11, timeDifference, "");
        if (player.currentFishingXp >= player.fishingXpForLevel) {
            levelUp(_playerId);
        }
        player.currentFishingXp += timeDifference;
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
        player.stamina = 20;
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
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }
}
