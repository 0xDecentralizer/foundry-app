// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Whitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    uint256 public constant _price = 0.01 ether;
    uint256 public constant maxTokenIds = 20;

    Whitelist whitelist;

    uint256 reservedTokens;
    uint256 reservedTokensClamied = 0;

    constructor(
        address whitelistContract
    ) ERC721("Crypto Devs", "CD") Ownable(msg.sender) {
        whitelist = Whitelist(whitelistContract);
        reservedTokens = whitelist.maxWhitelistedAddresses();
    }

    function mint() public payable {
        require(
            totalSupply() + reservedTokens - reservedTokensClamied <
                maxTokenIds,
            "EXEEDED_ MAX_SUPPLYQ"
        );

        if (whitelist.whitelistedAddresses(msg.sender) && msg.value < _price) {
            require(balanceOf(msg.sender) == 0, "ALREADY_OWNED");
            reservedTokensClamied += 1;
        } else {
            require(msg.value >= _price, "NOT_ENOUGH_ETHER");
        }
        uint256 tokenId = totalSupply();
        _safeMint(msg.sender, tokenId);
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send ether");
    }
}
