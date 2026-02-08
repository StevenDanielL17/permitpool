// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./interfaces/INameWrapper.sol";
import "./interfaces/IResolver.sol";

/// @title LicenseManager - Bulletproof ENS License Authority
/// @notice Issues trading licenses as ENS subdomains with escape hatches
contract LicenseManager is Ownable, ERC1155Holder {
    INameWrapper public immutable nameWrapper;
    IResolver public immutable textResolver;
    bytes32 public immutable parentNode;

    event LicenseIssued(address indexed licensee, bytes32 indexed subnode, string subdomain);

    constructor(address _nameWrapper, address _resolver, bytes32 _parentNode) Ownable(msg.sender) {
        nameWrapper = INameWrapper(_nameWrapper);
        textResolver = IResolver(_resolver);
        parentNode = _parentNode;
    }

    function issueLicense(
        address licensee,
        string calldata subdomain,
        string calldata arcCredentialHash
    ) external onlyOwner returns (bytes32) {
        bytes32 labelHash = keccak256(bytes(subdomain));
        bytes32 subnode = keccak256(abi.encodePacked(parentNode, labelHash));
        
        // 1. DYNAMIC EXPIRY: Fetch current parent expiry to avoid "0" errors
        (, , uint64 parentExpiry) = nameWrapper.getData(uint256(parentNode));
        require(parentExpiry > block.timestamp, "Parent expired or invalid");

        // 2. MINT TO SELF (Factory Pattern)
        nameWrapper.setSubnodeRecord(
            parentNode,
            subdomain,
            address(this),
            address(textResolver),
            0,
            0, // Clean fuses - no restrictions on subdomain
            parentExpiry
        );
        
        // 3. SET TEXT
        textResolver.setText(subnode, "arc.did", arcCredentialHash);
        
        // 4. SEND TO USER
        nameWrapper.safeTransferFrom(address(this), licensee, uint256(subnode), 1, "");
        
        emit LicenseIssued(licensee, subnode, subdomain);
        return subnode;
    }

    // --- ESCAPE HATCHES (Prevent "Coffin" Scenario) ---

    /// @notice Fix parent fuses/expiry if wrapping went wrong
    function setParentFuses(uint16 fuseMask) external onlyOwner returns (uint32) {
        return nameWrapper.setFuses(parentNode, fuseMask);
    }

    /// @notice Rescue the domain back to your wallet
    function emergencyWithdraw(address to) external onlyOwner {
        nameWrapper.safeTransferFrom(address(this), to, uint256(parentNode), 1, "");
    }
}
