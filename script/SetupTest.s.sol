// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";
import {MockArcOracle} from "../src/MockArcOracle.sol";

contract SetupTestScript is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        address licenseManagerAddr = vm.envAddress("LICENSE_MANAGER_ADDRESS");
        address arcOracleAddr = vm.envAddress("ARC_ORACLE_ADDRESS");
        address testUser = vm.envAddress("TEST_USER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        console.log("Setting up test data for user:", testUser);

        // 1. Issue Arc Credential
        if (arcOracleAddr != address(0)) {
            MockArcOracle oracle = MockArcOracle(arcOracleAddr);
            bytes32 credHash = keccak256(abi.encodePacked("test-credential"));
            
            // Check if already valid to avoid revert
            if (!oracle.isValidCredential(credHash)) {
                oracle.issueCredential(credHash, testUser);
                console.log("Issued credential hash:", vm.toString(credHash));
            } else {
                console.log("Credential already valid");
            }
        }

        // 2. Issue License
        if (licenseManagerAddr != address(0)) {
            LicenseManager manager = LicenseManager(licenseManagerAddr);
            
            // Note: LicenseManager must own the parent node for this to work
            // We try to issue a license for 'testuser' label
            try manager.issueLicense(testUser, "testuser", "valid-credential-hash") {
                console.log("License issued successfully");
            } catch Error(string memory reason) {
                console.log("License issuance failed:", reason);
            } catch {
                console.log("License issuance failed (unknown reason)");
            }
        }

        vm.stopBroadcast();
    }
}
