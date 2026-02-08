// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IResolver {
    function setText(bytes32 node, string calldata key, string calldata value) external;
}
