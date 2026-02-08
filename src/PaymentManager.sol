// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PaymentManager
/// @notice Manages Yellow Network payment sessions for license fees
/// @dev Integrates with Yellow Network to link payment sessions to licenses

// ============================================
// INTERFACES
// ============================================

/// @notice Yellow Network Clearnode Interface
interface IYellowClearnode {
    /// @notice Checks if a payment session is active
    /// @param sessionId The session identifier
    /// @return isActive True if session is active and paid up
    function isSessionActive(bytes32 sessionId) external view returns (bool isActive);

    function getSessionExpiry(bytes32 sessionId) external view returns (uint256);
    
    /// @notice Settles a session (off-chain balance to on-chain)
    function settleSession(bytes32 sessionId) external;

    function createSession(
        address[] calldata participants,
        address token,
        uint256 amount,
        uint256 duration
    ) external returns (bytes32);
}

// ============================================
// MAIN CONTRACT
// ============================================

/// @title PaymentManager
/// @notice Links Yellow Network payment sessions to ENS licenses
contract PaymentManager {
    
    // ============================================
    // STATE VARIABLES
    // ============================================
    
    /// @notice Contract administrator
    address public admin;
    
    /// @notice Yellow Network Clearnode contract
    IYellowClearnode public immutable clearnode;
    
    /// @notice Mapping of license nodes to Yellow session IDs
    /// @dev licenseNode => yellowSessionId
    mapping(bytes32 => bytes32) public licensePayments;
    
    /// @notice Mapping to track last payment timestamp
    mapping(bytes32 => uint256) public lastPayment;
    
    /// @notice Mapping to track when licenses were first issued (for grace period)
    mapping(bytes32 => uint256) public licenseIssuedAt;
    
    /// @notice Payment period (30 days)
    uint256 public constant PAYMENT_PERIOD = 30 days;
    
    /// @notice Grace period for new licenses (30 days)
    uint256 public constant GRACE_PERIOD = 30 days;
    
    /// @notice Mapping to track if a license requires payment
    /// @dev licenseNode => requiresPayment
    mapping(bytes32 => bool) public paymentRequired;

    // ============================================
    // EVENTS
    // ============================================
    
    event PaymentSessionLinked(bytes32 indexed licenseNode, bytes32 indexed yellowSessionId);
    event PaymentSessionUnlinked(bytes32 indexed licenseNode);
    event PaymentRequirementChanged(bytes32 indexed licenseNode, bool required);
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);
    event LicenseRegistered(bytes32 indexed licenseNode, uint256 issuedAt);
    
    // ============================================
    // ERRORS
    // ============================================
    
    error Unauthorized();
    error InvalidAddress();
    error InvalidSessionId();
    error InvalidLicenseNode();
    error PaymentOverdue();
    
    // ============================================
    // MODIFIERS
    // ============================================
    
    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized();
        _;
    }
    
    // ============================================
    // CONSTRUCTOR
    // ============================================
    
    constructor(address _clearnode, address _admin) {
        if (_clearnode == address(0)) revert InvalidAddress();
        if (_admin == address(0)) revert InvalidAddress();
        
        clearnode = IYellowClearnode(_clearnode);
        admin = _admin;
    }
    
    // ============================================
    // FUNCTIONS
    // ============================================
    
    function updateAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert InvalidAddress();
        address oldAdmin = admin;
        admin = newAdmin;
        emit AdminUpdated(oldAdmin, newAdmin);
    }
    
    function linkSession(bytes32 licenseNode, bytes32 sessionId) external onlyAdmin {
        if (licenseNode == bytes32(0)) revert InvalidLicenseNode();
        if (sessionId == bytes32(0)) revert InvalidSessionId();
        
        licensePayments[licenseNode] = sessionId;
        lastPayment[licenseNode] = block.timestamp;
        
        emit PaymentSessionLinked(licenseNode, sessionId);
    }
    
    function unlinkSession(bytes32 licenseNode) external onlyAdmin {
        if (licenseNode == bytes32(0)) revert InvalidLicenseNode();
        delete licensePayments[licenseNode];
        emit PaymentSessionUnlinked(licenseNode);
    }
    
    /// @notice Registers a newly issued license with grace period
    /// @param licenseNode The ENS node of the new license
    /// @dev Call this when issuing a license to grant 30-day grace period
    function registerNewLicense(bytes32 licenseNode) external onlyAdmin {
        if (licenseNode == bytes32(0)) revert InvalidLicenseNode();
        
        // Only register if not already registered (prevent resetting grace period)
        if (licenseIssuedAt[licenseNode] == 0) {
            licenseIssuedAt[licenseNode] = block.timestamp;
            emit LicenseRegistered(licenseNode, block.timestamp);
        }
    }

    /// @notice Sets whether payment is required for a license
    /// @param licenseNode The ENS node of the license
    /// @param required Whether payment should be required
    function setPaymentRequirement(bytes32 licenseNode, bool required) external onlyAdmin {
        if (licenseNode == bytes32(0)) revert InvalidLicenseNode();
        
        paymentRequired[licenseNode] = required;
        
        emit PaymentRequirementChanged(licenseNode, required);
    }
    
    /// @notice Checks if payment is active (Yellow session active AND not overdue)
    /// @dev New licenses get a 30-day grace period before payment is required
    function isPaymentCurrent(bytes32 licenseNode) external view returns (bool) {
        uint256 issuedAt = licenseIssuedAt[licenseNode];
        
        // If license was registered within grace period, payment is current
        if (issuedAt > 0 && block.timestamp < issuedAt + GRACE_PERIOD) {
            return true; // Grace period - no payment required yet!
        }
        
        // After grace period, check for active payment session
        bytes32 sessionId = licensePayments[licenseNode];
        if (sessionId == bytes32(0)) return false;
        
        // Check Yellow Network
        if (!clearnode.isSessionActive(sessionId)) {
            return false;
        }
        
        // Check if payment is within period
        return block.timestamp < lastPayment[licenseNode] + PAYMENT_PERIOD;
    }
    
    function settleSession(bytes32 sessionId) external {
        clearnode.settleSession(sessionId);
    }
}

