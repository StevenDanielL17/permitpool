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
    // Mock non-zero address to pass basic checks if any
    address constant POOL_MANAGER = address(0x88); 

    // Parent node for fund.eth (example value)
    bytes32 constant PARENT_NODE = keccak256(abi.encodePacked(bytes32(0), keccak256("fund")));

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Mocks (Arc & Yellow)
        MockArcVerifier arcVerifier = new MockArcVerifier();
        console.log("MockArcVerifier deployed at:", address(arcVerifier));

        MockYellowClearnode clearnode = new MockYellowClearnode();
        console.log("MockYellowClearnode deployed at:", address(clearnode));

        // 2. Deploy Real Contracts (using Mocks)
        ArcOracle arcOracle = new ArcOracle(address(arcVerifier));
        console.log("ArcOracle deployed at:", address(arcOracle));

        // 3. Deploy LicenseManager
        LicenseManager licenseManager = new LicenseManager(
            NAME_WRAPPER,
            RESOLVER,
            PARENT_NODE,
            deployer // admin
        );
        console.log("LicenseManager deployed at:", address(licenseManager));

        // 4. Deploy PaymentManager
        PaymentManager paymentManager = new PaymentManager(address(clearnode), deployer);
        console.log("PaymentManager deployed at:", address(paymentManager));

        // 5. Deploy PermitPoolHook
        // Mine a salt that produces a hook address with the correct flags
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG);
        bytes memory constructorArgs = abi.encode(
            IPoolManager(POOL_MANAGER), 
            NAME_WRAPPER, 
            RESOLVER, 
            PARENT_NODE, 
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
            IPoolManager(POOL_MANAGER),
            NAME_WRAPPER,
            RESOLVER,
            PARENT_NODE,
            deployer,
            address(arcOracle),
            address(paymentManager)
        );
        
        require(address(hook) == hookAddress, "Hook address mismatch");
        console.log("PermitPoolHook deployed at:", address(hook));

        vm.stopBroadcast();
    }
}
