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

    constructor(address _arcVerifier) {
        require(_arcVerifier != address(0), "Invalid verifier");
        arcVerifier = _arcVerifier;
    }

    function isCredentialValid(string calldata credentialJWT)
        external
        view
        returns (bool)
    {
        // Call Arc's on-chain verifier
        return IArcVerifier(arcVerifier).verify(credentialJWT);
    }
}
