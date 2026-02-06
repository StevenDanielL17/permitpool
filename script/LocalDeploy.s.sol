// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {MockArcVerifier} from "../src/MockArcVerifier.sol";
import {MockYellowClearnode} from "../src/MockYellowClearnode.sol";
import {ArcOracle} from "../src/ArcOracle.sol";
import {LicenseManager} from "../src/LicenseManager.sol";
import {PaymentManager} from "../src/PaymentManager.sol";
import {PermitPoolHook} from "../src/PermitPoolHook.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {HookMiner} from "v4-periphery/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

/**
 * Local deployment script for testing
 * Deploys all contracts to simulate what would happen on Sepolia
 * Use this before running the real deployment
 */
contract LocalDeployScript is Script {
    address constant NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;
    address constant RESOLVER = 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD;

    function run() external {
        address deployer = vm.envAddress("OWNER_ADDRESS");
        address poolManager = vm.envAddress("POOL_MANAGER");
        bytes32 parentNode = vm.envBytes32("PARENT_NODE");

        console.log("\n=== PermitPool Local Deployment ===\n");
        console.log("Config:");
        console.log("  Deployer:", deployer);
        console.log("  PoolManager:", poolManager);
        console.log("  NameWrapper:", NAME_WRAPPER);
        console.log("  Resolver:", RESOLVER);
        console.log("  ParentNode:", vm.toString(parentNode));
        console.log("");

        require(poolManager != address(0), "POOL_MANAGER not set");
        require(deployer != address(0), "OWNER_ADDRESS not set");
        require(parentNode != bytes32(0), "PARENT_NODE not set");

        console.log("OK: All required addresses configured\n");

        // This will deploy locally
        vm.startBroadcast();

        console.log("Step 1: Deploying Mock Contracts...");
        MockYellowClearnode yellowClearnode = new MockYellowClearnode();
        console.log("  OK MockYellowClearnode:", address(yellowClearnode));

        MockArcVerifier arcVerifier = new MockArcVerifier();
        console.log("  OK MockArcVerifier:", address(arcVerifier));

        console.log("\nStep 2: Deploying ArcOracle...");
        ArcOracle arcOracle = new ArcOracle(address(arcVerifier));
        console.log("  OK ArcOracle:", address(arcOracle));

        console.log("\nStep 3: Deploying PaymentManager...");
        PaymentManager paymentManager = new PaymentManager(address(yellowClearnode), deployer);
        console.log("  OK PaymentManager:", address(paymentManager));

        console.log("\nStep 4: Mining Hook Address...");
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG);
        bytes memory constructorArgs = abi.encode(
            IPoolManager(poolManager),
            NAME_WRAPPER,
            RESOLVER,
            parentNode,
            deployer,
            address(arcOracle),
            address(paymentManager)
        );

        (address hookAddress, bytes32 salt) = HookMiner.find(
            deployer,
            flags,
            type(PermitPoolHook).creationCode,
            constructorArgs
        );
        console.log("  OK Hook address mined:", hookAddress);

        console.log("\nStep 5: Deploying PermitPoolHook...");
        PermitPoolHook hook = new PermitPoolHook{salt: salt}(
            IPoolManager(poolManager),
            NAME_WRAPPER,
            RESOLVER,
            parentNode,
            deployer,
            address(arcOracle),
            address(paymentManager)
        );
        require(address(hook) == hookAddress, "Hook address mismatch");
        console.log("  OK PermitPoolHook:", address(hook));

        console.log("\nStep 6: Deploying LicenseManager...");
        LicenseManager licenseManager = new LicenseManager(
            NAME_WRAPPER,
            RESOLVER,
            address(hook),
            parentNode,
            deployer
        );
        console.log("  OK LicenseManager:", address(licenseManager));

        vm.stopBroadcast();

        console.log("\n=== Deployment Addresses ===");
        console.log("MockYellowClearnode: ", address(yellowClearnode));
        console.log("MockArcVerifier:     ", address(arcVerifier));
        console.log("ArcOracle:           ", address(arcOracle));
        console.log("PaymentManager:      ", address(paymentManager));
        console.log("PermitPoolHook:      ", address(hook));
        console.log("LicenseManager:      ", address(licenseManager));
        console.log("\nOK: Local Deployment Complete!\n");
    }
}
