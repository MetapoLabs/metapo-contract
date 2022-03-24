// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IBalanceListener {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function onMetapoBalanceChange(address account, bool increase, uint changeValue) external;
}