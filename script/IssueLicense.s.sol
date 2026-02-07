// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";

// Ensure this matches your deployment!
address constant LICENSE_MANAGER = 0xe8faf26e16068d2c6d77834b4441805c521a91b6;

contract IssueLicenseScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");
        
        // Settings for the license
        address licensee = 0x1234567890123456789012345678901234567890; // Replace with a real test address if needed
        string memory subdomain = "employee001";
        string memory arcCredentialHash = "did:arc:test-credential-hash-123";

        console.log("Issuing License via LicenseManager...");
        console.log("  Manager:", LICENSE_MANAGER);
        console.log("  Licensee:", licensee);
        console.log("  Subdomain:", subdomain);

        vm.startBroadcast(deployerPrivateKey);

        LicenseManager manager = LicenseManager(LICENSE_MANAGER);

        // Call the issueLicense function
        // This will:
        // 1. Create demo-trader.myhedgefund.eth
        // 2. Burn fuses (CANNOT_TRANSFER | PARENT_CANNOT_CONTROL)
        // 3. Set reference to Arc Credential
        // 4. Register in mapping
        try manager.issueLicense(licensee, subdomain, arcCredentialHash) returns (bytes32 node) {
            console.log("License Issued Successfully!");
            console.logBytes32(node);
        } catch Error(string memory reason) {
            console.log("Failed to issue license:", reason);
        } catch {
            console.log("Failed to issue license (unknown error)");
        }

        vm.stopBroadcast();
    }
}
