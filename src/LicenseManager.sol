// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title LicenseManager - PermitPool's Sole License Authority
/// @notice ONLY this contract can issue licenses
/// @dev Uses setSubnodeRecord for emancipated subdomain creation (bypasses PARENT_CANNOT_CONTROL)

// ============================================
// INTERFACES
// ============================================

interface INameWrapper {
    /// @notice Creates subdomain with immediate owner assignment (emancipated creation)
    /// @dev Works even when parent has PARENT_CANNOT_CONTROL fuse
    function setSubnodeRecord(
        bytes32 parentNode,
        string calldata label,
        address owner,
        address resolver,
        uint64 ttl,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node);
    
    function setFuses(bytes32 node, uint16 fuseMask) external returns (uint32 newFuses);
    
    function getData(uint256 id) external view returns (address owner, uint32 fuses, uint64 expiry);
    
    function getFuses(bytes32 node) external view returns (uint32);
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
    uint32 public constant CANNOT_UNWRAP = 0x1;
    uint32 public constant CANNOT_TRANSFER = 0x10;
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
    
    event ParentLocked(
        bytes32 indexed parentNode,
        uint32 newFuses
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
    
    // ============ PARENT LOCKING ============
    
    /// @notice Ensure parent domain is locked (has CANNOT_UNWRAP fuse)
    /// @dev CRITICAL: Parent must be locked before burning fuses on child subdomains
    /// @return wasAlreadyLocked True if already locked, false if we just locked it
    function ensureParentLocked() public onlyAdmin returns (bool wasAlreadyLocked) {
        // Get current parent fuses
        (, uint32 currentFuses, ) = NAME_WRAPPER.getData(uint256(PARENT_NODE));
        
        // Check if CANNOT_UNWRAP is already burned (parent is locked)
        if ((currentFuses & CANNOT_UNWRAP) != 0) {
            // Already locked - safe to proceed
            return true;
        }
        
        // Parent is NOT locked - burn CANNOT_UNWRAP to lock it
        // This is required by ENS NameWrapper to allow burning fuses on children
        uint32 newFuses = NAME_WRAPPER.setFuses(PARENT_NODE, uint16(CANNOT_UNWRAP));
        
        emit ParentLocked(PARENT_NODE, newFuses);
        
        return false; // Was not locked before, now it is
    }
    
    // ============ CORE FUNCTION: ISSUE LICENSE ============
    
    /// @notice ONLY way to get a license - called by admin after Arc verification
    /// @dev Uses setSubnodeRecord for emancipated creation (bypasses PARENT_CANNOT_CONTROL)
    /// @param licensee Trader's wallet address
    /// @param subdomain ENS subdomain (e.g., "alice")
    /// @param arcCredentialHash Arc credential hash from verification
    function issueLicense(
        address licensee,
        string calldata subdomain,
        string calldata arcCredentialHash
    ) external onlyAdmin returns (bytes32) {
        // Validation
        if (licensee == address(0)) revert InvalidAddress();
        if (bytes(subdomain).length == 0) revert InvalidLabel();
        if (bytes(arcCredentialHash).length == 0) revert InvalidCredentialHash();
        if (addressToLicense[licensee] != bytes32(0)) revert AlreadyLicensed();
        
        // CRITICAL FIX: Ensure parent is locked before burning child fuses
        // ENS requires parent to have CANNOT_UNWRAP before allowing child fuse burns
        ensureParentLocked();
        
        // CRITICAL: Get parent's expiry - child CANNOT exceed this
        // Passing type(uint64).max causes OperationProhibited revert
        (, , uint64 parentExpiry) = NAME_WRAPPER.getData(uint256(PARENT_NODE));
        
        // Burn fuses for non-transferable, emancipated, LOCKED license
        // MUST include CANNOT_UNWRAP + PARENT_CANNOT_CONTROL together (rule: cannot lock without emancipating)
        uint32 fusesToBurn = PARENT_CANNOT_CONTROL | CANNOT_UNWRAP | CANNOT_TRANSFER;
        
        // Step 1: Create subdomain with emancipated ownership
        // This bypasses PARENT_CANNOT_CONTROL by setting owner atomically at creation
        bytes32 licenseNode = NAME_WRAPPER.setSubnodeRecord(
            PARENT_NODE,
            subdomain,
            licensee,              // Direct owner assignment (emancipation)
            address(RESOLVER),     // Resolver for text records
            0,                     // TTL (0 = inherit from parent)
            fusesToBurn,           // Burn fuses immediately
            parentExpiry           // MUST match or be less than parent's expiry
        );
        
        // Step 2: Store Arc credential in ENS text record
        RESOLVER.setText(licenseNode, "arc.did", arcCredentialHash);
        
        // Step 3: Store in registry (source of truth for license validity)
        licenses[licenseNode] = LicenseData({
            holder: licensee,
            arcCredential: arcCredentialHash,
            issuedAt: block.timestamp,
            revoked: false
        });
        
        addressToLicense[licensee] = licenseNode;
        
        // Step 4: Register with Hook for swap verification
        HOOK.registerLicenseNode(licensee, licenseNode);
        
        emit LicenseIssued(licensee, subdomain, licenseNode, arcCredentialHash);
        
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
        
        // Verify subdomain still exists in NameWrapper
        (address owner, , ) = NAME_WRAPPER.getData(uint256(licenseNode));
        if (owner == address(0)) return false;
        
        // Verify fuses still burned (CANNOT_TRANSFER ensures non-transferability)
        uint32 fuses = NAME_WRAPPER.getFuses(licenseNode);
        if ((fuses & CANNOT_TRANSFER) == 0) return false;
        
        return true;
    }
    
    /// @notice Get license details
    /// @param holder Address to query
    /// @return node The license node
    /// @return arcCredential The Arc credential hash
    /// @return issuedAt Timestamp of issuance
    /// @return revoked Whether the license is revoked
    function getLicense(address holder) external view returns (
        bytes32 node,
        string memory arcCredential,
        uint256 issuedAt,
        bool revoked
    ) {
        node = addressToLicense[holder];
        LicenseData memory license = licenses[node];
        return (node, license.arcCredential, license.issuedAt, license.revoked);
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
