// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";

contract DeployNewLicenseManager is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");
        bytes32 parentNode = vm.envBytes32("PARENT_NODE");
        
        // Sepolia addresses
        address NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;
        address RESOLVER = 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD;

        console.log("Deploying NEW LicenseManager with setParentFuses function...");
        console.log("  Owner:", deployer);
        console.log("  Parent Node:", vm.toString(parentNode));

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new LicenseManager with updated functions
        LicenseManager newManager = new LicenseManager(
            NAME_WRAPPER,
            RESOLVER,
            parentNode
        );

        console.log("");
        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("New LicenseManager:", address(newManager));
        console.log("");
        console.log("NEXT STEPS:");
        console.log("1. Transfer parent from old contract to new:");
        console.log("   Use TransferParent.s.sol script");
        console.log("2. Set parent fuses to assign expiry:");
        console.log("   cast send <NEW_CONTRACT> 'setParentFuses(uint16)' 1");
        console.log("3. Test license issuance");

        vm.stopBroadcast();
    }
}
