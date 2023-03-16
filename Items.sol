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


    constructor() ERC1155("ENTER URL HERE") {
        // _mint(msg.sender, BRONZE_PICKAXE, 10**27, "");
        // _mint(msg.sender, IRON_PICKAXE, 10**27, "");
        // _mint(msg.sender, RUNE_PICKAXE, 10**27, "");
        // _mint(msg.sender, FISHING_ROD, 10**27, "");
        // _mint(msg.sender, BRONZE_LONGSWORD, 10**27, "");
        // _mint(msg.sender, IRON_LONGSWORD, 10**27, "");
        // _mint(msg.sender, RUNE_LONGSWORD, 10**27, "");
        // _mint(msg.sender, BRONZE_ARMOR, 10**27, "");
        // _mint(msg.sender, IRON_ARMOR, 10**27, "");
        // _mint(msg.sender, RUNE_ARMOR, 10**27, "");
        // _mint(msg.sender, SHRIMP, 10**27, "");
        // _mint(msg.sender, LOBSTER, 10**27, "");
        // _mint(msg.sender, SHARK, 10**27, "");
        // _mint(msg.sender, GOLD, 10**27, "");
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

    function craftItems(uint256 _itemId, uint256 _amount)  public {
        if (_itemId == BRONZE_FULL_HELM) {
            require(balanceOf(msg.sender, BRONZE_BAR) > 2 * _amount, "Missing Required materials");
            // Burn here
         //   safeTransferFrom(msg.sender, address(this), BRONZE_BAR, 2 * _amount, "");
       //     burn(msg.sender, BRONZE_BAR, 2 * _amount);
            mint(msg.sender, BRONZE_FULL_HELM, _amount, "");
        }        
    }

    function smithOre(uint256 _itemId, uint256 _amount) public {
        if (_itemId == BRONZE_BAR) {
            require(balanceOf(msg.sender, TIN_ORE) > _amount && balanceOf(msg.sender, COPPER_ORE) > _amount, "Missing Required materials");
            // BURN
         //   safeTransferFrom(msg.sender, address(this), TIN_ORE, _amount, "");
      //      burn(msg.sender, TIN_ORE, _amount);
       //     burn(msg.sender, COPPER_ORE, _amount);
          //  safeTransferFrom(msg.sender, address(this), COPPER_ORE, _amount, "");
            mint(msg.sender, BRONZE_BAR, _amount, "");
        }
    }
}
