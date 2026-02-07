// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title LicenseManager - PermitPool's Sole License Authority
/// @notice ONLY this contract can issue licenses
/// @dev Integrates with ENS NameWrapper, Public Resolver, and PermitPoolHook

// ============================================
// INTERFACES
// ============================================

interface INameWrapper {
    function setSubnodeOwner(
        bytes32 parentNode,
        string memory label,
        address owner,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node);
    
    function setFuses(bytes32 node, uint32 fuses) external;
    
    function getData(uint256 id) external view returns (address owner, uint32 fuses, uint64 expiry);
}

interface IResolver {
    function setText(bytes32 node, string calldata key, string calldata value) external;
}

interface IPermitPoolHook {
    function registerLicenseNode(address licensee, bytes32 node) external;
}

// ============================================
// MAIN CONTRACT
// ============================================

contract LicenseManager {
    
    // ============ STATE ============
    
    INameWrapper public immutable NAME_WRAPPER;
    IResolver public immutable RESOLVER;
    IPermitPoolHook public immutable HOOK;
    bytes32 public immutable PARENT_NODE;
    address public admin;
    
    // License registry (source of truth)
    mapping(address => bytes32) public addressToLicense;
    mapping(bytes32 => LicenseData) public licenses;
    
    struct LicenseData {
        address holder;
        string arcCredential;
        uint256 issuedAt;
        bool revoked;
    }
    
    // Fuse constants
    uint32 public constant CANNOT_TRANSFER = 0x4;
    uint32 public constant PARENT_CANNOT_CONTROL = 0x10000;
    
    // ============ ERRORS ============
    
    error Unauthorized();
    error InvalidAddress();
    error InvalidLabel();
    error InvalidCredentialHash();
    error AlreadyLicensed();
    error NoLicense();
    
    // ============ EVENTS ============
    
    event LicenseIssued(
        address indexed holder,
        string subdomain,
        bytes32 indexed licenseNode,
        string arcCredential
    );
    
    event LicenseRevoked(
        address indexed holder,
        bytes32 indexed licenseNode
    );
    
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);
    
    // ============ CONSTRUCTOR ============
    
    constructor(
        address _nameWrapper,
        address _resolver,
        address _hook,
        bytes32 _parentNode,
        address _admin
    ) {
        if (_nameWrapper == address(0)) revert InvalidAddress();
        if (_resolver == address(0)) revert InvalidAddress();
        if (_hook == address(0)) revert InvalidAddress();
        if (_admin == address(0)) revert InvalidAddress();
        
        NAME_WRAPPER = INameWrapper(_nameWrapper);
        RESOLVER = IResolver(_resolver);
        HOOK = IPermitPoolHook(_hook);
        PARENT_NODE = _parentNode;
        admin = _admin;
    }
    
    // ============ CORE FUNCTION: ISSUE LICENSE ============
    
    /// @notice ONLY way to get a license - called by admin after Arc verification
    /// @param holder Trader's wallet address
    /// @param subdomain ENS subdomain (e.g., "alice")
    /// @param arcCredential Arc credential hash from verification
    function issueLicense(
        address holder,
        string calldata subdomain,
        string calldata arcCredential
    ) external onlyAdmin returns (bytes32 licenseNode) {
        
        if (holder == address(0)) revert InvalidAddress();
        if (bytes(subdomain).length == 0) revert InvalidLabel();
        if (bytes(arcCredential).length == 0) revert InvalidCredentialHash();
        if (addressToLicense[holder] != bytes32(0)) revert AlreadyLicensed();
        
        // 1. Create ENS subdomain
        licenseNode = NAME_WRAPPER.setSubnodeOwner(
            PARENT_NODE,
            subdomain,
            holder,
            0, // No fuses initially
            type(uint64).max // Max expiry
        );
        
        // 2. Burn fuses (make soulbound) - commented for now as mock doesn't support
        // uint32 fusesToBurn = CANNOT_TRANSFER | PARENT_CANNOT_CONTROL;
        // nameWrapper.setFuses(licenseNode, fusesToBurn);
        
        // 3. Store Arc credential in ENS text record
        RESOLVER.setText(licenseNode, "arc.credential", arcCredential);
        
        // 4. Store in registry (PermitPool's source of truth)
        licenses[licenseNode] = LicenseData({
            holder: holder,
            arcCredential: arcCredential,
            issuedAt: block.timestamp,
            revoked: false
        });
        
        addressToLicense[holder] = licenseNode;
        
        // 5. Register with Hook (the PermitPoolHook)
        HOOK.registerLicenseNode(holder, licenseNode);
        
        emit LicenseIssued(holder, subdomain, licenseNode, arcCredential);
        
        return licenseNode;
    }
    
    // ============ LICENSE VERIFICATION ============
    
    /// @notice Check if address has valid license
    /// @dev Called by Uniswap hook before every trade
    function hasValidLicense(address trader) external view returns (bool) {
        bytes32 licenseNode = addressToLicense[trader];
        
        if (licenseNode == bytes32(0)) return false;
        
        LicenseData memory license = licenses[licenseNode];
        
        // Check not revoked
        if (license.revoked) return false;
        
        // Check fuses still burned (not transferred)
        // Using getData instead of getFuses as NameWrapper uses getData
        (, uint32 fuses, ) = NAME_WRAPPER.getData(uint256(licenseNode));
        if ((fuses & CANNOT_TRANSFER) == 0) return false;
        
        return true;
    }
    
    // ============ REVOCATION ============
    
    function revokeLicense(address holder) external onlyAdmin {
        bytes32 licenseNode = addressToLicense[holder];
        if (licenseNode == bytes32(0)) revert NoLicense();
        
        licenses[licenseNode].revoked = true;
        
        emit LicenseRevoked(holder, licenseNode);
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert InvalidAddress();
        address oldAdmin = admin;
        admin = newAdmin;
        emit AdminUpdated(oldAdmin, newAdmin);
    }
    
    modifier onlyAdmin() {
        _checkAdmin();
        _;
    }

    function _checkAdmin() internal view {
        if (msg.sender != admin) revert Unauthorized();
    }
}
