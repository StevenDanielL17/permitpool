// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title LicenseManager
/// @notice Issues ENS subdomains as licenses with burned fuses and Arc DID credentials
/// @dev Integrates with ENS NameWrapper and Public Resolver

// ============================================
// INTERFACES
// ============================================

/// @notice ENS NameWrapper interface for subdomain management and fuse control
interface INameWrapper {
    /// @notice Creates a subdomain under a parent node
    /// @param parentNode The parent namehash
    /// @param label The subdomain label (e.g., "alice" for alice.fund.eth)
    /// @param owner The new owner address
    /// @param fuses The fuses to burn
    /// @param expiry Expiration timestamp (0 for never)
    /// @return node The namehash of the created subdomain
    function setSubnodeOwner(
        bytes32 parentNode,
        string memory label,
        address owner,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node);
    
    /// @notice Burns additional fuses on an existing node
    /// @param node The namehash to burn fuses on
    /// @param fuses The fuses to burn
    function setFuses(bytes32 node, uint32 fuses) external;
}

/// @notice ENS Public Resolver interface for text record storage
interface IResolver {
    /// @notice Sets a text record for a node
    /// @param node The namehash
    /// @param key The text record key
    /// @param value The text record value
    function setText(bytes32 node, string calldata key, string calldata value) external;
}

// ============================================
// MAIN CONTRACT
// ============================================

/// @title LicenseManager
/// @notice Manages ENS-based trading licenses with cryptographic credentials
contract LicenseManager {
    
    // ============================================
    // STATE VARIABLES
    // ============================================
    
    /// @notice ENS NameWrapper contract
    INameWrapper public immutable nameWrapper;
    
    /// @notice ENS Public Resolver contract
    IResolver public immutable resolver;
    
    /// @notice Parent ENS node (e.g., namehash of "fund.eth")
    bytes32 public immutable parentNode;
    
    /// @notice Contract administrator
    address public admin;
    
    /// @notice ENS fuse constants
    uint32 public constant CANNOT_TRANSFER = 0x4;              // Bit 2
    uint32 public constant PARENT_CANNOT_CONTROL = 0x10000;    // Bit 16
    
    /// @notice Text record key for Arc DID credentials
    string public constant ARC_CREDENTIAL_KEY = "arc.did";
    
    // ============================================
    // EVENTS
    // ============================================
    
    /// @notice Emitted when a license is issued
    /// @param licensee The address receiving the license
    /// @param label The subdomain label
    /// @param node The namehash of the subdomain
    /// @param arcCredentialHash The Arc DID credential hash
    event LicenseIssued(
        address indexed licensee,
        string label,
        bytes32 indexed node,
        string arcCredentialHash
    );
    
    /// @notice Emitted when admin is updated
    /// @param oldAdmin Previous admin address
    /// @param newAdmin New admin address
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);
    
    // ============================================
    // ERRORS
    // ============================================
    
    /// @notice Thrown when caller is not admin
    error Unauthorized();
    
    /// @notice Thrown when address is zero
    error InvalidAddress();
    
    /// @notice Thrown when label is empty
    error InvalidLabel();
    
    /// @notice Thrown when credential hash is empty
    error InvalidCredentialHash();
    
    // ============================================
    // MODIFIERS
    // ============================================
    
    /// @notice Restricts function access to admin only
    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized();
        _;
    }
    
    // ============================================
    // CONSTRUCTOR
    // ============================================
    
    /// @notice Initializes the LicenseManager
    /// @param _nameWrapper ENS NameWrapper contract address
    /// @param _resolver ENS Public Resolver contract address
    /// @param _parentNode Parent ENS node (e.g., namehash of "fund.eth")
    /// @param _admin Initial admin address
    constructor(
        address _nameWrapper,
        address _resolver,
        bytes32 _parentNode,
        address _admin
    ) {
        // Validate inputs
        if (_nameWrapper == address(0)) revert InvalidAddress();
        if (_resolver == address(0)) revert InvalidAddress();
        if (_admin == address(0)) revert InvalidAddress();
        
        nameWrapper = INameWrapper(_nameWrapper);
        resolver = IResolver(_resolver);
        parentNode = _parentNode;
        admin = _admin;
    }
    
    // ============================================
    // ADMIN FUNCTIONS
    // ============================================
    
    /// @notice Updates the contract administrator
    /// @param newAdmin New admin address
    function updateAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert InvalidAddress();
        
        address oldAdmin = admin;
        admin = newAdmin;
        
        emit AdminUpdated(oldAdmin, newAdmin);
    }
    
    // ============================================
    // LICENSE ISSUANCE
    // ============================================
    
    /// @notice Issues a trading license by creating an ENS subdomain with burned fuses
    /// @param licensee The address to receive the license
    /// @param label The subdomain label (e.g., "alice" for alice.fund.eth)
    /// @param arcCredentialHash The Arc DID credential hash to store in text records
    /// @return node The namehash of the created subdomain
    function issueLicense(
        address licensee,
        string calldata label,
        string calldata arcCredentialHash
    ) external onlyAdmin returns (bytes32 node) {
        // Validate inputs
        if (licensee == address(0)) revert InvalidAddress();
        if (bytes(label).length == 0) revert InvalidLabel();
        if (bytes(arcCredentialHash).length == 0) revert InvalidCredentialHash();
        
        // Calculate fuses to burn
        uint32 fusesToBurn = CANNOT_TRANSFER | PARENT_CANNOT_CONTROL;
        
        // Create subdomain with burned fuses
        // expiry = 0 means the name never expires
        node = nameWrapper.setSubnodeOwner(
            parentNode,
            label,
            licensee,
            fusesToBurn,
            uint64(0) // No expiration
        );
        
        // Store Arc DID credential in ENS text records
        resolver.setText(node, ARC_CREDENTIAL_KEY, arcCredentialHash);
        
        // Emit license issuance event
        emit LicenseIssued(licensee, label, node, arcCredentialHash);
        
        return node;
    }
}
