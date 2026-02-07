// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

interface INameWrapper {
    function setFuses(bytes32 node, uint32 fuses) external returns (uint32);
}

contract BurnParentFuses is Script {
    address constant NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;
    uint32 constant PARENT_CANNOT_CONTROL = 0x10000;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        bytes32 parentNode = vm.envBytes32("PARENT_NODE");
        
        console.log("Burning PARENT_CANNOT_CONTROL fuse on parent domain...");
        
        vm.startBroadcast(deployerPrivateKey);
        
        INameWrapper(NAME_WRAPPER).setFuses(parentNode, PARENT_CANNOT_CONTROL);
        
        console.log("Fuse burned successfully!");
        
        vm.stopBroadcast();
    }
}
