// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

// Addresses on Sepolia
address constant NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;
address constant LICENSE_MANAGER = 0xBE033f15f64A8aE139cD8bCDf000603Ec100A01B; 

interface INameWrapper {
    function setApprovalForAll(address operator, bool approved) external;
    function ownerOf(uint256 id) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract FixAndIssueLicenseScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");
        
        // This is the Namehash for 'myhedgefund.eth'
        // namehash('eth') = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae
        // labelhash('myhedgefund') = keccak256('myhedgefund') = 0xdf02b0c1441a54a0f44357c3e5cb0ad79ac9a8a652d886a5120613297071e223
        // namehash = keccak256(namehash('eth') + labelhash('myhedgefund'))
        bytes32 node = 0x5c7ff35237c2a59c3cfa914cbc481abf5b6e11a7fae301b8290d0a0deed3deb9;
        
        vm.startBroadcast(deployerPrivateKey);

        INameWrapper wrapper = INameWrapper(NAME_WRAPPER);
        
        // 1. Check current owner of the node on NameWrapper
        address currentOwner = wrapper.ownerOf(uint256(node));
        console.log("NameWrapper Owner of myhedgefund.eth (node):", currentOwner);
        console.log("Expected Owner (Deployer):", deployer);

        if (currentOwner != deployer) {
            console.log("CRITICAL WARN: Owner Mismatch.");
            console.log("HOWEVER: Proceeding to approve LicenseManager anyway as instructed.");
            console.log("If the deployer is an approved operator for the REAL owner, this might still work.");
        }

        // 2. Force Approval for LicenseManager
        // This approves LicenseManager to act on behalf of the deployer for ALL names the deployer owns on NameWrapper.
        console.log("Approving LicenseManager on NameWrapper...");
        wrapper.setApprovalForAll(LICENSE_MANAGER, true);
        
        bool isApproved = wrapper.isApprovedForAll(deployer, LICENSE_MANAGER);
        console.log("Is LicenseManager approved now?", isApproved);
        
        require(isApproved, "Approval failed");

        vm.stopBroadcast();
    }
}
