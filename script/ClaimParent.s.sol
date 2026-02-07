// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";

// Ensure this matches your deployment!
address constant LICENSE_MANAGER = 0xBE033f15f64A8aE139cD8bCDf000603Ec100A01B;
address constant OWNER = 0x52b34414Df3e56ae853BC4A0EB653231447C2A36;

interface INameWrapper {
    function setSubnodeOwner(
        bytes32 parentNode,
        string memory label,
        address owner,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node);
}

// Parent Node: myhedgefund.eth (Sepolia)
bytes32 constant PARENT_NODE = 0x5c7ff35237c2a59c3cfa914cbc481abf5b6e11a7fae301b8290d0a0deed3deb9;

contract ClaimParentScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");

        // We suspect the deployer doesn't own the parent node on the NameWrapper yet.
        // It might be owned on the Registry but not wrapped.
        // Or it might be just un-initialized in this test context.
        
        vm.startBroadcast(deployerPrivateKey);

        // NOTE: In a real mainnet/testnet scenario, you must already OWN "myhedgefund.eth".
        // If "myhedgefund.eth" is not yours, you CANNOT issue subdomains.
        
        // Let's try to verify what we can about the parent node.
        console.log("Checking Parent Node ownership...");
        // Since the previous script showed ownerOf(parentNode) == 0, it means the NameWrapper
        // does NOT have the record wrapped or it doesn't exist.
        
        // Use Case A: You own the name in the old Registry but haven't wrapped it.
        // Action: You need to wrap it using the NameWrapper contract via the Registrar.
        
        // Use Case B: You don't own the name at all.
        // Action: You must register it first or use a name you own.
        
        console.log("CRITICAL: Ensure 'myhedgefund.eth' is registered and wrapped by:", deployer);
        console.log("If this script fails, go to ens.domains on Sepolia and register/wrap the name.");

        vm.stopBroadcast();
    }
}
