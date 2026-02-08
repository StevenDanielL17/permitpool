// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title INameWrapper
 * @notice Interface for the ENS NameWrapper contract (Sepolia)
 */
interface INameWrapper {
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function setApprovalForAll(address operator, bool approved) external;
    function ownerOf(uint256 id) external view returns (address);

    function getData(uint256 id) external view returns (address owner, uint32 fuses, uint64 expiry);

    function setSubnodeRecord(
        bytes32 parentNode,
        string calldata label,
        address owner,
        address resolver,
        uint64 ttl,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node);

    function setFuses(bytes32 node, uint16 fuseMask) external returns (uint32);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}
