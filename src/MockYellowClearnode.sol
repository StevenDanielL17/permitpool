// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MockYellowClearnode {
    mapping(bytes32 => bool) public active;
    
    function setSession(bytes32 id, bool isActive) external {
        active[id] = isActive;
    }

    function isSessionActive(bytes32 sessionId) external view returns (bool) {
        return active[sessionId];
    }
    
    function settleSession(bytes32) external {}

    function getSessionExpiry(bytes32) external pure returns (uint256) {
        return 0;
    }

    function createSession(
        address[] calldata participants,
        address token,
        uint256 amount,
        uint256 duration
    ) external returns (bytes32) {
        return keccak256(abi.encodePacked(participants, token, amount, duration));
    }
}
