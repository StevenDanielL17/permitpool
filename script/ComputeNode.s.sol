// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";

contract ComputeNodeScript is Script {
    function run() external pure {
        // Calculate namehash for myhedgefund-v2.eth
        // namehash("eth") = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae
        bytes32 ethNode = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
        bytes32 labelHash = keccak256(bytes("myhedgefund-v2"));
        bytes32 parentNode = keccak256(abi.encodePacked(ethNode, labelHash));
        
        console.log("Name: myhedgefund-v2.eth");
        console.log("LabelHash (myhedgefund-v2):");
        console.logBytes32(labelHash);
        
        console.log("Parent Node (myhedgefund-v2.eth):");
        console.logBytes32(parentNode);
    }
}
