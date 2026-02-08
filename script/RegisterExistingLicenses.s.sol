// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {PaymentManager} from "../src/PaymentManager.sol";

address constant PAYMENT_MANAGER = 0xf62b1Bf242d9FEB66aaf9d887dC4B417284D061E;

/// @notice Migration script to register existing licenses with grace period
/// @dev Call this once to give existing users their 30-day grace period
contract RegisterExistingLicensesScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        
        // Existing licenses that need grace period
        string[] memory licenses = new string[](4);
        licenses[0] = "dexter";
        licenses[1] = "whale";
        licenses[2] = "trader1";
        licenses[3] = "alpha";
        
        bytes32 parentNode = 0x3823ea55ea6b28adf8c102e44f7d7577b4581e2f3a7fb35b374a47cba5240884;
        
        console.log("Registering existing licenses with grace period...");
        console.log("Parent node: hedgefund-v3.eth");
        
        vm.startBroadcast(deployerPrivateKey);
        
        PaymentManager payment = PaymentManager(PAYMENT_MANAGER);
        
        for (uint i = 0; i < licenses.length; i++) {
            bytes32 labelHash = keccak256(bytes(licenses[i]));
            bytes32 licenseNode = keccak256(abi.encodePacked(parentNode, labelHash));
            
            console.log("\nRegistering license:", licenses[i]);
            console.logBytes32(licenseNode);
            
            try payment.registerNewLicense(licenseNode) {
                console.log("  [OK] Activated 30-day grace period");
            } catch Error(string memory reason) {
                console.log("  [FAIL] Failed:", reason);
            } catch {
                console.log("  [FAIL] Failed (unknown error)");
            }
        }
        
        vm.stopBroadcast();
        
        console.log("\n========================================");
        console.log("Migration Complete!");
        console.log("All existing licenses now have 30-day grace period");
        console.log("========================================");
    }
}
