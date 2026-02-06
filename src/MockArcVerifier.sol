// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MockArcVerifier {
    mapping(bytes32 => bool) public validCredentials;

    function setValid(string calldata jwt) external {
        validCredentials[keccak256(bytes(jwt))] = true;
    }

    function verifyCredential(bytes32 /* credentialHash */) external pure returns (bool) {
        // For testing: always return true
        // In production, this would check validCredentials[credentialHash]
        return true;
    }
}
