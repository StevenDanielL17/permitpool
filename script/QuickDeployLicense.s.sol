// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";

contract QuickDeployLicenseScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");
        bytes32 parentNode = vm.envBytes32("PARENT_NODE");
        
        // Sepolia addresses
        address NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;
        address RESOLVER = 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD;
        
        // Existing deployed contracts (from previous deployment)
        address HOOK = 0x62Dcd43Af88Fa08fDe758445bCb32fF872190080;

        console.log("Deploying LicenseManager with:");
        console.log("  Owner:", deployer);
        console.log("  Parent Node:", vm.toString(parentNode));
        console.log("  NameWrapper:", NAME_WRAPPER);
        console.log("  Resolver:", RESOLVER);
        console.log("  Hook:", HOOK);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy LicenseManager
        LicenseManager licenseManager = new LicenseManager(
            NAME_WRAPPER,
            RESOLVER,
            HOOK,
            parentNode,
            deployer
        );

        console.log("");
        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("LicenseManager:", address(licenseManager));
        
        // Approve NameWrapper to manage ENS names
        console.log("");
        console.log("Setting NameWrapper approval...");
        (bool success,) = NAME_WRAPPER.call(
            abi.encodeWithSignature(
                "setApprovalForAll(address,bool)",
                address(licenseManager),
                true
            )
        );
        require(success, "Failed to set approval");
        console.log("Approval set!");

        vm.stopBroadcast();
    }
}
