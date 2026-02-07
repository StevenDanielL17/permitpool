// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title INameWrapper
 * @notice Interface for the ENS NameWrapper contract
 * @dev Minimal interface with only the functions needed for license management
 */
interface INameWrapper {
    /**
     * @notice Check if an operator is approved to manage all names for an owner
     * @param account The owner address
     * @param operator The operator address to check
     * @return True if the operator is approved for all
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @notice Approve or revoke an operator for all names owned by the caller
     * @param operator The operator address
     * @param approved True to approve, false to revoke
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @notice Get the owner of a wrapped ENS name
     * @param id The namehash/tokenId of the name
     * @return The owner address
     */
    function ownerOf(uint256 id) external view returns (address);

    /**
     * @notice Get the fuses and expiry of a wrapped name
     * @param node The namehash of the name
     * @return fuses The fuses set on the name
     * @return expiry The expiry timestamp
     */
    function getData(bytes32 node) external view returns (uint32 fuses, uint64 expiry);
}
