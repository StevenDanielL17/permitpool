// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title MockArcOracle
/// @notice Mock implementation of Arc identity verification oracle for testing
/// @dev Simulates Arc's credential verification system for testnet deployment

contract MockArcOracle {
    
    // ============================================
    // STATE VARIABLES
    // ============================================
    
    /// @notice Contract administrator
    address public admin;
    
    /// @notice Mapping of credential hashes to their validity status
    /// @dev credentialHash => isValid
    mapping(bytes32 => bool) public validCredentials;
    
    // ============================================
    // EVENTS
    // ============================================
    
    /// @notice Emitted when a credential is issued
    /// @param credentialHash The hash of the issued credential
    /// @param holder The address associated with the credential
    event CredentialIssued(bytes32 indexed credentialHash, address indexed holder);
    
    /// @notice Emitted when a credential is revoked
    /// @param credentialHash The hash of the revoked credential
    /// @param holder The address associated with the credential
    event CredentialRevoked(bytes32 indexed credentialHash, address indexed holder);
    
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
    
    /// @notice Thrown when credential hash is zero
    error InvalidCredentialHash();
    
    /// @notice Thrown when trying to issue an already valid credential
    error CredentialAlreadyValid();
    
    /// @notice Thrown when trying to revoke an already invalid credential
    error CredentialAlreadyInvalid();
    
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
    
    /// @notice Initializes the MockArcOracle
    /// @param _admin Initial admin address
    constructor(address _admin) {
        if (_admin == address(0)) revert InvalidAddress();
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
    // CREDENTIAL MANAGEMENT
    // ============================================
    
    /// @notice Issues a new credential, marking it as valid
    /// @param credentialHash The hash of the credential to issue
    /// @param holder The address associated with the credential
    function issueCredential(bytes32 credentialHash, address holder) external onlyAdmin {
        if (credentialHash == bytes32(0)) revert InvalidCredentialHash();
        if (holder == address(0)) revert InvalidAddress();
        if (validCredentials[credentialHash]) revert CredentialAlreadyValid();
        
        validCredentials[credentialHash] = true;
        
        emit CredentialIssued(credentialHash, holder);
    }
    
    /// @notice Revokes an existing credential, marking it as invalid
    /// @param credentialHash The hash of the credential to revoke
    /// @param holder The address associated with the credential
    function revokeCredential(bytes32 credentialHash, address holder) external onlyAdmin {
        if (credentialHash == bytes32(0)) revert InvalidCredentialHash();
        if (!validCredentials[credentialHash]) revert CredentialAlreadyInvalid();
        
        validCredentials[credentialHash] = false;
        
        emit CredentialRevoked(credentialHash, holder);
    }
    
    /// @notice Checks if a credential is currently valid
    /// @param credentialHash The hash of the credential to check
    /// @return isValid True if the credential is valid, false otherwise
    function isValidCredential(bytes32 credentialHash) external view returns (bool isValid) {
        return validCredentials[credentialHash];
    }
    
    /// @notice Batch issue multiple credentials
    /// @param credentialHashes Array of credential hashes to issue
    /// @param holders Array of addresses associated with each credential
    function batchIssueCredentials(
        bytes32[] calldata credentialHashes,
        address[] calldata holders
    ) external onlyAdmin {
        if (credentialHashes.length != holders.length) revert InvalidCredentialHash();
        
        for (uint256 i = 0; i < credentialHashes.length; i++) {
            bytes32 credHash = credentialHashes[i];
            address holder = holders[i];
            
            if (credHash == bytes32(0)) revert InvalidCredentialHash();
            if (holder == address(0)) revert InvalidAddress();
            if (validCredentials[credHash]) continue; // Skip already valid credentials
            
            validCredentials[credHash] = true;
            emit CredentialIssued(credHash, holder);
        }
    }
}

