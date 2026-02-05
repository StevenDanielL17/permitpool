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
    
    function settle(bytes32) external {}
}
