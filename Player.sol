// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.2/utils/Counters.sol";

contract Player is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("CantoScapePlayer", "CSP") {}

    struct Player {
        uint8 fishingLevel;
        uint8 cookingLevel;
        uint8 miningLevel;
        uint8 smithingLevel;
        uint8 meleeLevel;
        uint8 hitpointsLevel;
        uint8 stamina;
        uint256 fishingXp;
        uint256 cookingXp;
        uint256 miningXp;
        uint256 smithingXp;
        uint256 meleeXp;
        uint256 hitpointsXp;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmQnfPjmxYsv8fkEWmav7GmyRaPmnrs9AeW2Jw5KL2oW1o/";
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}
