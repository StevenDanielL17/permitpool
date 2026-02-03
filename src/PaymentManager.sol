// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PaymentManager
/// @notice Manages Yellow Network payment sessions for license fees
/// @dev Integrates with Yellow Network to link payment sessions to licenses

// ============================================
// INTERFACES
// ============================================

/// @notice Mock Yellow Network session interface for testing
interface IYellowSession {
    /// @notice Checks if a payment session is active
    /// @param sessionId The session identifier
    /// @return isActive True if session is active and paid up
    function isSessionActive(bytes32 sessionId) external view returns (bool isActive);
    
    /// @notice Gets the expiry timestamp of a session
    /// @param sessionId The session identifier
    /// @return expiry The Unix timestamp when session expires
    function getSessionExpiry(bytes32 sessionId) external view returns (uint256 expiry);
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
    
    /// @notice Yellow Network session contract
    IYellowSession public immutable yellowSession;
    
    /// @notice Mapping of license nodes to Yellow session IDs
    /// @dev licenseNode => yellowSessionId
    mapping(bytes32 => bytes32) public licensePayments;
    
   /// @notice Mapping to track if a license requires payment
    /// @dev licenseNode => requiresPayment
    mapping(bytes32 => bool) public paymentRequired;
    
    // ============================================
    // EVENTS
    // ============================================
    
    /// @notice Emitted when a payment session is linked to a license
    /// @param licenseNode The ENS node of the license
    /// @param yellowSessionId The Yellow Network session ID
    event PaymentSessionLinked(bytes32 indexed licenseNode, bytes32 indexed yellowSessionId);
    
    /// @notice Emitted when a payment session is unlinked from a license
    /// @param licenseNode The ENS node of the license
    event PaymentSessionUnlinked(bytes32 indexed licenseNode);
    
    /// @notice Emitted when payment requirement is toggled
    /// @param licenseNode The ENS node of the license
    /// @param required Whether payment is now required
    event PaymentRequirementChanged(bytes32 indexed licenseNode, bool required);
    
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
    
    /// @notice Thrown when session ID is zero
    error InvalidSessionId();
    
    /// @notice Thrown when license node is zero
    error InvalidLicenseNode();
    
    /// @notice Thrown when payment is overdue
    error PaymentOverdue();
    
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
    
    /// @notice Initializes the PaymentManager
    /// @param _yellowSession Yellow Network session contract address
    /// @param _admin Initial admin address
    constructor(address _yellowSession, address _admin) {
        if (_yellowSession == address(0)) revert InvalidAddress();
        if (_admin == address(0)) revert InvalidAddress();
        
        yellowSession = IYellowSession(_yellowSession);
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
    // PAYMENT SESSION MANAGEMENT
    // ============================================
    
    /// @notice Links a Yellow payment session to a license
    /// @param licenseNode The ENS node of the license
    /// @param yellowSessionId The Yellow Network session ID
    function setPaymentSession(bytes32 licenseNode, bytes32 yellowSessionId) external onlyAdmin {
        if (licenseNode == bytes32(0)) revert InvalidLicenseNode();
        if (yellowSessionId == bytes32(0)) revert InvalidSessionId();
        
        licensePayments[licenseNode] = yellowSessionId;
        paymentRequired[licenseNode] = true;
        
        emit PaymentSessionLinked(licenseNode, yellowSessionId);
    }
    
    /// @notice Unlinks a payment session from a license
    /// @param licenseNode The ENS node of the license
    function unlinkPaymentSession(bytes32 licenseNode) external onlyAdmin {
        if (licenseNode == bytes32(0)) revert InvalidLicenseNode();
        
        delete licensePayments[licenseNode];
        
        emit PaymentSessionUnlinked(licenseNode);
    }
    
    /// @notice Sets whether payment is required for a license
    /// @param licenseNode The ENS node of the license
    /// @param required Whether payment should be required
    function setPaymentRequirement(bytes32 licenseNode, bool required) external onlyAdmin {
        if (licenseNode == bytes32(0)) revert InvalidLicenseNode();
        
        paymentRequired[licenseNode] = required;
        
        emit PaymentRequirementChanged(licenseNode, required);
    }
    
    /// @notice Checks if payment is active for a license
    /// @param licenseNode The ENS node of the license
    /// @return isActive True if payment is active or not required
    function isPaymentActive(bytes32 licenseNode) external view returns (bool isActive) {
        // If payment not required, always return true
        if (!paymentRequired[licenseNode]) {
            return true;
        }
        
        // Get the Yellow session ID
        bytes32 sessionId = licensePayments[licenseNode];
        
        // If no session linked, payment is not active
        if (sessionId == bytes32(0)) {
            return false;
        }
        
        // Check Yellow Network for session status
        return yellowSession.isSessionActive(sessionId);
    }
    
    /// @notice Checks if payment is active and reverts if not
    /// @param licenseNode The ENS node of the license
    function requireActivePayment(bytes32 licenseNode) external view {
        if (!this.isPaymentActive(licenseNode)) {
            revert PaymentOverdue();
        }
    }
    
    /// @notice Gets the payment session expiry time
    /// @param licenseNode The ENS node of the license
    /// @return expiry The Unix timestamp when payment expires (0 if not required)
    function getPaymentExpiry(bytes32 licenseNode) external view returns (uint256 expiry) {
        if (!paymentRequired[licenseNode]) {
            return 0;
        }
        
        bytes32 sessionId = licensePayments[licenseNode];
        if (sessionId == bytes32(0)) {
            return 0;
        }
        
        return yellowSession.getSessionExpiry(sessionId);
    }
}

