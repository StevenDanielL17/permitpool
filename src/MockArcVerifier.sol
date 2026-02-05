// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MockArcVerifier {
    mapping(string => bool) public validCredentials;

    function setValid(string calldata jwt) external {
        validCredentials[jwt] = true;
    }

    function verify(string calldata jwt) external view returns (bool) {
        return validCredentials[jwt];
    }
}
