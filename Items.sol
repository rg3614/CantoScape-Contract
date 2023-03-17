// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.8.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC1155/extensions/ERC1155Supply.sol";

contract CantoScapeItems is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {

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

    struct equipmentBonuses {
        uint256 attackBonus;
        uint256 defenseBonus;
    }

    mapping(uint256 => equipmentBonuses) public EquipmentBonuses;

    constructor() ERC1155("ENTER URL HERE") {
        EquipmentBonuses[0] = equipmentBonuses(0,0);
        EquipmentBonuses[BRONZE_FULL_HELM] = equipmentBonuses(0,3);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
