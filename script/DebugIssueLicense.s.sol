// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";

contract DebugIssueLicenseScript is Script {
    address constant LICENSE_MANAGER = 0x8a7B23126dD019ab706c3532cD54c90e4Fd861D3;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        
        console.log("=== Debugging License Issuance ===");
        
        LicenseManager manager = LicenseManager(LICENSE_MANAGER);
        
        // Check contract state
        console.log("LicenseManager:", address(manager));
        console.log("Owner:", manager.owner());
        console.log("Parent Node:");
        console.logBytes32(manager.parentNode());
        
        // Test parameters
        address licensee = 0x9999999999999999999999999999999999999999;
        string memory subdomain = "debugtest";
        string memory arcCred = "did:arc:debug";
        
        console.log("\nAttempting to call issueLicense...");
        console.log("Licensee:", licensee);
        console.log("Subdomain:", subdomain);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Try to simulate the call
        try manager.issueLicense(licensee, subdomain, arcCred) returns (bytes32 node) {
            console.log("SUCCESS!");
            console.logBytes32(node);
        } catch Error(string memory reason) {
            console.log("REVERT:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("LOW LEVEL REVERT:");
            console.logBytes(lowLevelData);
        }
        
        vm.stopBroadcast();
    }
}
