// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {LicenseManager} from "../src/LicenseManager.sol";
import {PermitPoolHook} from "../src/PermitPoolHook.sol";
import {ArcOracle} from "../src/ArcOracle.sol";
import {MockArcVerifier} from "../src/MockArcVerifier.sol";
import {PaymentManager} from "../src/PaymentManager.sol";
import {MockYellowClearnode} from "../src/MockYellowClearnode.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "v4-periphery/utils/HookMiner.sol";

/*//////////////////////////////////////////////////////////////
                         MOCK CONTRACTS
//////////////////////////////////////////////////////////////*/

contract MockNameWrapper {
    function setSubnodeOwner(
        bytes32 parentNode,
        string memory label,
        address owner,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node) {
        node = keccak256(abi.encodePacked(parentNode, keccak256(bytes(label))));
        return node;
    }
}

contract MockTextResolver {
    mapping(bytes32 => mapping(string => string)) public textRecords;
    
    function setText(bytes32 node, string memory key, string memory value) external {
        textRecords[node][key] = value;
    }
}

contract MockPoolManager {}

/*//////////////////////////////////////////////////////////////
                        INTEGRATION TEST
//////////////////////////////////////////////////////////////*/

contract LicenseIntegrationTest is Test {
    LicenseManager public licenseManager;
    PermitPoolHook public hook;
    
    MockNameWrapper public nameWrapper;
    MockTextResolver public resolver;
    MockArcVerifier public arcVerifier;
    MockYellowClearnode public clearnode;
    
    address public admin = address(0xAD);
    address public licensee = address(0x1);
    bytes32 public parentNode = keccak256("permitpool");
    
    function setUp() public {
        nameWrapper = new MockNameWrapper();
        resolver = new MockTextResolver();
        arcVerifier = new MockArcVerifier();
        clearnode = new MockYellowClearnode();
        
        ArcOracle arcOracle = new ArcOracle(address(arcVerifier));
        PaymentManager paymentManager = new PaymentManager(address(clearnode), admin);
        
        // 1. Deploy Hook
        bytes memory constructorArgs = abi.encode(
            IPoolManager(address(new MockPoolManager())), 
            address(nameWrapper), 
            address(resolver), 
            parentNode, 
            admin,
            address(arcOracle),
            address(paymentManager)
        );
        
        (address hookAddress, bytes32 salt) = HookMiner.find(
            address(this),
            uint160(Hooks.BEFORE_SWAP_FLAG),
            type(PermitPoolHook).creationCode,
            constructorArgs
        );
        
        hook = new PermitPoolHook{salt: salt}(
            IPoolManager(address(new MockPoolManager())), 
            address(nameWrapper), 
            address(resolver), 
            parentNode, 
            admin,
            address(arcOracle),
            address(paymentManager)
        );
        
        // 2. Deploy LicenseManager
        licenseManager = new LicenseManager(
            address(nameWrapper),
            address(resolver),
            address(hook),
            parentNode,
            admin
        );
        
        // 3. Link them (The Fix)
        vm.prank(admin);
        hook.setLicenseManager(address(licenseManager));
    }
    
    function test_LicenseIssuance_Success() public {
        string memory credential = "valid_credential";
        
        // Setup Arc Verified Credential
        arcVerifier.setValid(credential);
        
        // Issue License as Admin
        vm.startPrank(admin);
        licenseManager.issueLicense(licensee, "alice", credential);
        vm.stopPrank();
        
        // Verify Hook Effect
        // The licensee should now have a registered node in the hook
        bytes32 registeredNode = hook.userLicenseNode(licensee);
        bytes32 expectedNode = keccak256(abi.encodePacked(parentNode, keccak256(bytes("alice"))));
        
        assertEq(registeredNode, expectedNode, "License node not registered in Hook");
        console.log("License successfully issued and registered!");
    }
    
    function test_LicenseIssuance_FailsBeforeLink() public {
        // Reset Logic: Unset license manager to simulate bug
        vm.prank(admin);
        hook.setLicenseManager(address(0)); // Or address(1)
        
        string memory credential = "valid_credential";
        arcVerifier.setValid(credential);
        
        vm.startPrank(admin);
        // Should revert because LicenseManager is not authorized on Hook
        vm.expectRevert(PermitPoolHook.Unauthorized.selector); 
        licenseManager.issueLicense(licensee, "bob", credential);
        vm.stopPrank();
    }
}
