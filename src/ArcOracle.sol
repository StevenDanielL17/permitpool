// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @notice Interface for Arc's on-chain verifier
interface IArcVerifier {
    function verify(string calldata jwt) external view returns (bool);
}

/// @title ArcOracle
/// @notice Integrating Real Arc Block DID Verification
contract ArcOracle {
    // Arc's verifier contract address
    address public immutable arcVerifier;

    address public admin;
    
    event CredentialVerified(bytes32 indexed credentialHash, address indexed subject, bool valid);
    
    constructor(address _arcVerifier) {
        require(_arcVerifier != address(0), "Invalid verifier");
        arcVerifier = _arcVerifier;
        admin = msg.sender;
    }
    
    /// @notice Verify a credential using Circle's verifier
    /// @param credentialHash The hash of the credential JWT
    /// @return valid True if credential is valid
    function isValidCredential(bytes32 credentialHash) 
        external 
        view 
        returns (bool valid) 
    {
        // Call Circle's verifier contract
        (bool success, bytes memory data) = arcVerifier.staticcall(
            abi.encodeWithSignature("verifyCredential(bytes32)", credentialHash)
        );
        
        if (!success) return false;
        return abi.decode(data, (bool));
    }
    
    function updateAdmin(address newAdmin) external {
        require(msg.sender == admin, "Only admin");
        admin = newAdmin;
    }
}
