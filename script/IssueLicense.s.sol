// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";
import {PaymentManager} from "../src/PaymentManager.sol";

// Ensure this matches your deployment!
address constant LICENSE_MANAGER = 0x514f6121AE60E411f4d88708Eed7A2489817d06C;
address constant PAYMENT_MANAGER = 0xf62b1Bf242d9FEB66aaf9d887dC4B417284D061E;

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
        PaymentManager payment = PaymentManager(PAYMENT_MANAGER);

        // Call the issueLicense function
        // This will:
        // 1. Create subdomain.hedgefund-v3.eth
        // 2. Set reference to Arc Credential
        // 3. Transfer to licensee
        try manager.issueLicense(licensee, subdomain, arcCredentialHash) returns (bytes32 node) {
            console.log("License Issued Successfully!");
            console.logBytes32(node);
            
            // Register the license with PaymentManager for 30-day grace period
            try payment.registerNewLicense(node) {
                console.log("Grace Period Activated: No payment required for 30 days");
            } catch Error(string memory reason) {
                console.log("Warning: Failed to register grace period:", reason);
            }
        } catch Error(string memory reason) {
            console.log("Failed to issue license:", reason);
        } catch {
            console.log("Failed to issue license (unknown error)");
        }

        vm.stopBroadcast();
    }
}
