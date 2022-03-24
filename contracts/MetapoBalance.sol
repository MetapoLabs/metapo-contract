//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/StructuredLinkedList.sol";
import "./IBalanceListener.sol";
import "hardhat/console.sol";


contract MetapoBalance is Ownable {
    using StructuredLinkedList for StructuredLinkedList.List;

    mapping(address => uint256) public balanceOf;

    StructuredLinkedList.List public listenerList;

    constructor() {
        
    }

    function addBalanceListener(address contractAddress) public {
        require(contractAddress.code.length > 0, "is not contract");

        uint id = uint(uint160(contractAddress));
        if (!listenerList.nodeExists(id)) {
            listenerList.pushBack(id);
            console.log("[MetapoBalance][addBalanceListener] contractAddress", contractAddress, id);
        }
    }

    function setBalance(address account, uint newValue) public onlyOwner {
        uint oldValue = balanceOf[account];
        if (newValue == oldValue) return;

        balanceOf[account] = newValue;

        bool increase;
        uint changeValue;
        if (newValue > oldValue) {
            increase = true;
            changeValue = newValue - oldValue;
        } else {
            increase = false;
            changeValue =  oldValue - newValue;
        }

        uint currNode = 0;
        while (true) {
            (bool exist, uint id) = listenerList.getNextNode(currNode);
            if (id == 0) break;
            
            currNode = id;
            address contractAddress = address(uint160(id));
            console.log("[MetapoBalance][setBalance] contractAddress", contractAddress, exist);
            IBalanceListener(contractAddress).onMetapoBalanceChange(account, increase, changeValue);
        }
    }

}
