// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {LicenseManager} from "../src/LicenseManager.sol";

/// @title LicenseManagerTest
/// @notice Comprehensive test suite for LicenseManager contract
contract LicenseManagerTest is Test {
    
    // ============================================
    // STATE VARIABLES
    // ============================================
    
    LicenseManager public licenseManager;
    MockNameWrapper public nameWrapper;
    MockResolver public resolver;
    
    address public admin = address(0x1);
    address public alice = address(0x2);
    address public bob = address(0x3);
    
    bytes32 public constant PARENT_NODE = keccak256(abi.encodePacked(bytes32(0), keccak256("eth")));
    
    // ============================================
    // SETUP
    // ============================================
    
    function setUp() public {
        // Deploy mocks
        nameWrapper = new MockNameWrapper();
        resolver = new MockResolver();
        
        // Deploy LicenseManager
        vm.prank(admin);
        licenseManager = new LicenseManager(
            address(nameWrapper),
            address(resolver),
            PARENT_NODE,
            admin
        );
    }
    
    // ============================================
    // DEPLOYMENT TESTS
    // ============================================
    
    function test_Deployment() public view {
        assertEq(address(licenseManager.nameWrapper()), address(nameWrapper));
        assertEq(address(licenseManager.resolver()), address(resolver));
        assertEq(licenseManager.parentNode(), PARENT_NODE);
        assertEq(licenseManager.admin(), admin);
    }
    
    function test_DeploymentRevertsWithZeroNameWrapper() public {
        vm.expectRevert(LicenseManager.InvalidAddress.selector);
        new LicenseManager(address(0), address(resolver), PARENT_NODE, admin);
    }
    
    function test_DeploymentRevertsWithZeroResolver() public {
        vm.expectRevert(LicenseManager.InvalidAddress.selector);
        new LicenseManager(address(nameWrapper), address(0), PARENT_NODE, admin);
    }
    
    function test_DeploymentRevertsWithZeroAdmin() public {
        vm.expectRevert(LicenseManager.InvalidAddress.selector);
        new LicenseManager(address(nameWrapper), address(resolver), PARENT_NODE, address(0));
    }
    
    // ============================================
    // LICENSE ISSUANCE TESTS
    // ============================================
    
    function test_IssueLicense_Success() public {
        string memory label = "alice";
        string memory arcCredential = "did:arc:12345";
        
        vm.prank(admin);
        bytes32 node = licenseManager.issueLicense(alice, label, arcCredential);
        
        // Verify NameWrapper was called correctly
        assertEq(nameWrapper.lastOwner(), alice);
        assertEq(nameWrapper.lastLabel(), label);
        assertEq(nameWrapper.lastFuses(), 0x4 | 0x10000); // CANNOT_TRANSFER | PARENT_CANNOT_CONTROL
        
        // Verify Resolver was called correctly
        assertEq(resolver.lastNode(), node);
        assertEq(resolver.lastKey(), "arc.did");
        assertEq(resolver.lastValue(), arcCredential);
    }
    
    function test_IssueLicense_EmitsEvent() public {
        string memory label = "bob";
        string memory arcCredential = "did:arc:67890";
        
        bytes32 expectedNode = keccak256(abi.encodePacked(PARENT_NODE, keccak256(bytes(label))));
        
        vm.expectEmit(true, true, false, true);
        emit LicenseManager.LicenseIssued(bob, label, expectedNode, arcCredential);
        
        vm.prank(admin);
        licenseManager.issueLicense(bob, label, arcCredential);
    }
    
    function test_IssueLicense_RevertsNonAdmin() public {
        vm.prank(alice);
        vm.expectRevert(LicenseManager.Unauthorized.selector);
        licenseManager.issueLicense(bob, "test", "did:arc:123");
    }
    
    function test_IssueLicense_RevertsZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(LicenseManager.InvalidAddress.selector);
        licenseManager.issueLicense(address(0), "test", "did:arc:123");
    }
    
    function test_IssueLicense_RevertsEmptyLabel() public {
        vm.prank(admin);
        vm.expectRevert(LicenseManager.InvalidLabel.selector);
        licenseManager.issueLicense(alice, "", "did:arc:123");
    }
    
    function test_IssueLicense_RevertsEmptyCredential() public {
        vm.prank(admin);
        vm.expectRevert(LicenseManager.InvalidCredentialHash.selector);
        licenseManager.issueLicense(alice, "test", "");
    }
    
    // ============================================
    // ADMIN MANAGEMENT TESTS
    // ============================================
    
    function test_UpdateAdmin_Success() public {
        address newAdmin = address(0x999);
        
        vm.prank(admin);
        licenseManager.updateAdmin(newAdmin);
        
        assertEq(licenseManager.admin(), newAdmin);
    }
    
    function test_UpdateAdmin_EmitsEvent() public {
        address newAdmin = address(0x888);
        
        vm.expectEmit(true, true, false, false);
        emit LicenseManager.AdminUpdated(admin, newAdmin);
        
        vm.prank(admin);
        licenseManager.updateAdmin(newAdmin);
    }
    
    function test_UpdateAdmin_RevertsNonAdmin() public {
        vm.prank(alice);
        vm.expectRevert(LicenseManager.Unauthorized.selector);
        licenseManager.updateAdmin(bob);
    }
    
    function test_UpdateAdmin_RevertsZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(LicenseManager.InvalidAddress.selector);
        licenseManager.updateAdmin(address(0));
    }
    
    // ============================================
    // CONSTANTS VERIFICATION
    // ============================================
    
    function test_FuseConstants() public view {
        assertEq(licenseManager.CANNOT_TRANSFER(), 0x4);
        assertEq(licenseManager.PARENT_CANNOT_CONTROL(), 0x10000);
    }
    
    function test_ArcCredentialKey() public view {
        assertEq(licenseManager.ARC_CREDENTIAL_KEY(), "arc.did");
    }
}

// ============================================
// MOCK CONTRACTS
// ============================================

contract MockNameWrapper {
    address public lastOwner;
    string public lastLabel;
    uint32 public lastFuses;
    
    function setSubnodeOwner(
        bytes32 parentNode,
        string memory label,
        address owner,
        uint32 fuses,
        uint64 /* expiry */
    ) external returns (bytes32 node) {
        lastOwner = owner;
        lastLabel = label;
        lastFuses = fuses;
        
        // Return mock namehash
        node = keccak256(abi.encodePacked(parentNode, keccak256(bytes(label))));
        return node;
    }
    
    function setFuses(bytes32 /* node */, uint32 /* fuses */) external {
        // Mock implementation
    }
}

contract MockResolver {
    bytes32 public lastNode;
    string public lastKey;
    string public lastValue;
    
    function setText(bytes32 node, string calldata key, string calldata value) external {
        lastNode = node;
        lastKey = key;
        lastValue = value;
    }
}
