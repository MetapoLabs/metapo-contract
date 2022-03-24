//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MetapoBalance.sol";
import "./IBalanceListener.sol";
import "./libraries/StructuredLinkedList.sol";
import "hardhat/console.sol";

contract Entry is ERC721("Entry", "Entry"), Ownable, ReentrancyGuard, IBalanceListener {
    using StructuredLinkedList for StructuredLinkedList.List;

    MetapoBalance public metapoBalance;

    uint public minted;

    struct Info {
        uint[] upIds;
        string thumbnail;
        string content;
        address author;
        uint hot;
    }

    //NFT Info
    mapping(uint => Info) public tokenIdToInfo;

    //MetapoBalance amount of an account pointing to all Entries
    mapping(address => uint) public accountToPointed;

    //MetapoBalance amount of an account pointing to an Entry
    mapping(address => mapping(uint => uint)) public accountEntryPointed;

    //Entries of an account pointing to, using for onMetapoBalanceChange
    mapping(address => StructuredLinkedList.List) public accountPointedList;

    constructor() {
        
    }

    function setMetapoBalanceContract(address contractAddress) public onlyOwner {
        metapoBalance = MetapoBalance(contractAddress);
        metapoBalance.addBalanceListener(address(this));
    }

    //thumbnail as tokenURI
    function tokenURI(uint tokenId) override public view returns (string memory) {
        return tokenIdToInfo[tokenId].thumbnail;
    }

    function mint(uint[] memory upIds, string memory thumbnail, string memory content) public nonReentrant {
        require(upIds.length <= 5, "to many upIds");
        minted++;
        tokenIdToInfo[minted] = Info(upIds, thumbnail, content, _msgSender(), 0);
        _safeMint(_msgSender(), minted);
    }

    function like(uint tokenId, uint amount) public {
        require(amount >= 2, "amount not enough");

        Info memory info = tokenIdToInfo[tokenId];
        require(info.author != address(0), "Entry not exist");

        uint pointed = accountToPointed[_msgSender()];
        require(pointed + amount <= metapoBalance.balanceOf(_msgSender()), "not enough MetapoBalance");

        //add pointing amount
        accountToPointed[_msgSender()] += amount;
        accountEntryPointed[_msgSender()][tokenId] += amount;

        //add to account's pointed Entry list
        StructuredLinkedList.List storage list = accountPointedList[_msgSender()];
        if (!list.nodeExists(tokenId)) {
            list.pushBack(tokenId);
        }

        //add Hot up and up
        addHot(tokenId, amount);
    }

    function addHot(uint tokenId, uint amount) internal {
        if (amount < 2) return;
        Info memory info = tokenIdToInfo[tokenId];
        if (info.author == address(0)) return;

        uint hot = sqrt(amount); //Quadratic voting
        tokenIdToInfo[tokenId].hot += hot;

        uint index = 0;
        while (index < info.upIds.length) {
            addHot(info.upIds[index], hot);
            index++;
        }
    }

    function unlike(uint tokenId) public {
        uint amount = accountEntryPointed[_msgSender()][tokenId];
        require(amount > 0, "you haven't pointed this entry");

        Info memory info = tokenIdToInfo[tokenId];
        require(info.author != address(0), "Entry not exist");

        //remove pointing amount
        accountToPointed[_msgSender()] -= amount;
        accountEntryPointed[_msgSender()][tokenId] = 0;

        //remove from account's pointed Entry list
        StructuredLinkedList.List storage list = accountPointedList[_msgSender()];
        if (list.nodeExists(tokenId)) {
            list.remove(tokenId);
        }

        //remove hot up and up
        removeHot(tokenId, amount);
    }

    function removeHot(uint tokenId, uint amount) internal {
        Info memory info = tokenIdToInfo[tokenId];
        if (info.author == address(0)) return;

        uint hot = sqrt(amount); //Quadratic voting
        tokenIdToInfo[tokenId].hot -= hot;

        uint index = 0;
        while (index < info.upIds.length) {
            removeHot(info.upIds[index], hot);
            index++;
        }
    }

    //auto unlike the last Entry of the pointed Entry list, untill the account's Pointed less then his metapoBalance
    function onMetapoBalanceChange(address account, bool increase, uint changeValue) override external {
        if (increase) return;

        uint pointed = accountToPointed[account];
        uint count = 0;
        while (pointed > metapoBalance.balanceOf(account)) {
            //remove from account's pointed Entry list
            StructuredLinkedList.List storage list = accountPointedList[account];
            uint tokenId = list.popFront();
            if (tokenId == 0) break;

            uint amount = accountEntryPointed[account][tokenId];
            if (amount == 0) break;

            //remove pointing amount
            accountToPointed[account] -= amount;
            accountEntryPointed[account][tokenId] = 0;

            //remove hot up and up
            removeHot(tokenId, amount);
            if (++count == 10) break; //max loop, save gas
        }
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

}
