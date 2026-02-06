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

contract DeployScript is Script {
    // Sepolia addresses (update if needed)
    address constant NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;
    address constant RESOLVER = 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD;
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");
        
        // Load Addresses from Env
        address poolManager = vm.envAddress("POOL_MANAGER");
        bytes32 parentNode = vm.envBytes32("PARENT_NODE");

        console.log("Deploying PermitPool with:");
        console.log("  Owner:", deployer);
        console.log("  PoolManager:", poolManager);

        require(poolManager != address(0), "POOL_MANAGER not set");
        require(parentNode != bytes32(0), "PARENT_NODE not set");

        vm.startBroadcast(deployerPrivateKey);

        // 0. Deploy Mock Contracts (since they're marked as 0x... in .env)
        MockYellowClearnode yellowClearnodeInstance = new MockYellowClearnode();
        console.log("MockYellowClearnode deployed at:", address(yellowClearnodeInstance));
        
        MockArcVerifier arcVerifierInstance = new MockArcVerifier();
        console.log("MockArcVerifier deployed at:", address(arcVerifierInstance));

        // 1. Deploy ArcOracle
        ArcOracle arcOracle = new ArcOracle(address(arcVerifierInstance));
        console.log("ArcOracle deployed at:", address(arcOracle));

        // 2. Deploy PaymentManager
        PaymentManager paymentManager = new PaymentManager(address(yellowClearnodeInstance), deployer);
        console.log("PaymentManager deployed at:", address(paymentManager));

        // 3. Deploy PermitPoolHook first (needed by LicenseManager)
        // Mine a salt that produces a hook address with the correct flags
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
        console.log("PermitPoolHook deployed at:", address(hook));

        // 4. Deploy LicenseManager with hook address
        LicenseManager licenseManager = new LicenseManager(
            NAME_WRAPPER,
            RESOLVER,
            address(hook),
            address(arcOracle),
            parentNode,
            deployer // admin
        );
        console.log("LicenseManager deployed at:", address(licenseManager));

        vm.stopBroadcast();
    }
}
