// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {MockArcOracle} from "../src/MockArcOracle.sol";

/// @title MockArcOracleTest
/// @notice Comprehensive test suite for MockArcOracle contract
contract MockArcOracleTest is Test {
    
    MockArcOracle public oracle;
    
    address public admin = address(0x1);
    address public alice = address(0x2);
    address public bob = address(0x3);
    
    bytes32 public constant CREDENTIAL_1 = keccak256("alice-credential");
    bytes32 public constant CREDENTIAL_2 = keccak256("bob-credential");
    
    function setUp() public {
        vm.prank(admin);
        oracle = new MockArcOracle(admin);
    }
    
    // ============================================
    // DEPLOYMENT TESTS
    // ============================================
    
    function test_Deployment() public view {
        assertEq(oracle.admin(), admin);
    }
    
    function test_DeploymentRevertsWithZeroAdmin() public {
        vm.expectRevert(MockArcOracle.InvalidAddress.selector);
        new MockArcOracle(address(0));
    }
    
    // ============================================
    // CREDENTIAL ISSUANCE TESTS
    // ============================================
    
    function test_IssueCredential_Success() public {
        vm.prank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        
        assertTrue(oracle.validCredentials(CREDENTIAL_1));
        assertTrue(oracle.isValidCredential(CREDENTIAL_1));
    }
    
    function test_IssueCredential_EmitsEvent() public {
        vm.expectEmit(true, true, false, false);
        emit MockArcOracle.CredentialIssued(CREDENTIAL_1, alice);
        
        vm.prank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
    }
    
    function test_IssueCredential_RevertsNonAdmin() public {
        vm.prank(alice);
        vm.expectRevert(MockArcOracle.Unauthorized.selector);
        oracle.issueCredential(CREDENTIAL_1, alice);
    }
    
    function test_IssueCredential_RevertsZeroHash() public {
        vm.prank(admin);
        vm.expectRevert(MockArcOracle.InvalidCredentialHash.selector);
        oracle.issueCredential(bytes32(0), alice);
    }
    
    function test_IssueCredential_RevertsZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(MockArcOracle.InvalidAddress.selector);
        oracle.issueCredential(CREDENTIAL_1, address(0));
    }
    
    function test_IssueCredential_RevertsAlreadyValid() public {
        vm.startPrank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        
        vm.expectRevert(MockArcOracle.CredentialAlreadyValid.selector);
        oracle.issueCredential(CREDENTIAL_1, alice);
        vm.stopPrank();
    }
    
    // ============================================
    // CREDENTIAL REVOCATION TESTS
    // ============================================
    
    function test_RevokeCredential_Success() public {
        vm.startPrank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        oracle.revokeCredential(CREDENTIAL_1, alice);
        vm.stopPrank();
        
        assertFalse(oracle.validCredentials(CREDENTIAL_1));
        assertFalse(oracle.isValidCredential(CREDENTIAL_1));
    }
    
    function test_RevokeCredential_EmitsEvent() public {
        vm.startPrank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        
        vm.expectEmit(true, true, false, false);
        emit MockArcOracle.CredentialRevoked(CREDENTIAL_1, alice);
        
        oracle.revokeCredential(CREDENTIAL_1, alice);
        vm.stopPrank();
    }
    
    function test_RevokeCredential_RevertsNonAdmin() public {
        vm.prank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        
        vm.prank(alice);
        vm.expectRevert(MockArcOracle.Unauthorized.selector);
        oracle.revokeCredential(CREDENTIAL_1, alice);
    }
    
    function test_RevokeCredential_RevertsAlreadyInvalid() public {
        vm.prank(admin);
        vm.expectRevert(MockArcOracle.CredentialAlreadyInvalid.selector);
        oracle.revokeCredential(CREDENTIAL_1, alice);
    }
    
    // ============================================
    // VALIDITY CHECK TESTS
    // ============================================
    
    function test_IsValidCredential_ReturnsFalseByDefault() public view {
        assertFalse(oracle.isValidCredential(CREDENTIAL_1));
    }
    
    function test_IsValidCredential_ReturnsTrueAfterIssuance() public {
        vm.prank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        
        assertTrue(oracle.isValidCredential(CREDENTIAL_1));
    }
    
    function test_IsValidCredential_ReturnsFalseAfterRevocation() public {
        vm.startPrank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        oracle.revokeCredential(CREDENTIAL_1, alice);
        vm.stopPrank();
        
        assertFalse(oracle.isValidCredential(CREDENTIAL_1));
    }
    
    // ============================================
    // BATCH ISSUANCE TESTS
    // ============================================
    
    function test_BatchIssueCredentials_Success() public {
        bytes32[] memory credentials = new bytes32[](2);
        credentials[0] = CREDENTIAL_1;
        credentials[1] = CREDENTIAL_2;
        
        address[] memory holders = new address[](2);
        holders[0] = alice;
        holders[1] = bob;
        
        vm.prank(admin);
        oracle.batchIssueCredentials(credentials, holders);
        
        assertTrue(oracle.isValidCredential(CREDENTIAL_1));
        assertTrue(oracle.isValidCredential(CREDENTIAL_2));
    }
    
    function test_BatchIssueCredentials_SkipsAlreadyValid() public {
        vm.prank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        
        bytes32[] memory credentials = new bytes32[](2);
        credentials[0] = CREDENTIAL_1; // Already valid
        credentials[1] = CREDENTIAL_2;
        
        address[] memory holders = new address[](2);
        holders[0] = alice;
        holders[1] = bob;
        
        vm.prank(admin);
        oracle.batchIssueCredentials(credentials, holders);
        
        assertTrue(oracle.isValidCredential(CREDENTIAL_1));
        assertTrue(oracle.isValidCredential(CREDENTIAL_2));
    }
    
    function test_BatchIssueCredentials_RevertsNonAdmin() public {
        bytes32[] memory credentials = new bytes32[](1);
        credentials[0] = CREDENTIAL_1;
        
        address[] memory holders = new address[](1);
        holders[0] = alice;
        
        vm.prank(alice);
        vm.expectRevert(MockArcOracle.Unauthorized.selector);
        oracle.batchIssueCredentials(credentials, holders);
    }
    
    function test_BatchIssueCredentials_RevertsArrayLengthMismatch() public {
        bytes32[] memory credentials = new bytes32[](2);
        credentials[0] = CREDENTIAL_1;
        credentials[1] = CREDENTIAL_2;
        
        address[] memory holders = new address[](1);
        holders[0] = alice;
        
        vm.prank(admin);
        vm.expectRevert(MockArcOracle.InvalidCredentialHash.selector);
        oracle.batchIssueCredentials(credentials, holders);
    }
    
    // ============================================
    // ADMIN MANAGEMENT TESTS
    // ============================================
    
    function test_UpdateAdmin_Success() public {
        vm.prank(admin);
        oracle.updateAdmin(alice);
        
        assertEq(oracle.admin(), alice);
    }
    
    function test_UpdateAdmin_EmitsEvent() public {
        vm.expectEmit(true, true, false, false);
        emit MockArcOracle.AdminUpdated(admin, alice);
        
        vm.prank(admin);
        oracle.updateAdmin(alice);
    }
    
    function test_UpdateAdmin_RevertsNonAdmin() public {
        vm.prank(alice);
        vm.expectRevert(MockArcOracle.Unauthorized.selector);
        oracle.updateAdmin(bob);
    }
    
    function test_UpdateAdmin_RevertsZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(MockArcOracle.InvalidAddress.selector);
        oracle.updateAdmin(address(0));
    }
    
    // ============================================
    // INTEGRATION TESTS
    // ============================================
    
    function test_FullCredentialLifecycle() public {
        // Issue
        vm.prank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        assertTrue(oracle.isValidCredential(CREDENTIAL_1));
        
        // Revoke
        vm.prank(admin);
        oracle.revokeCredential(CREDENTIAL_1, alice);
        assertFalse(oracle.isValidCredential(CREDENTIAL_1));
        
        // Re-issue
        vm.prank(admin);
        oracle.issueCredential(CREDENTIAL_1, alice);
        assertTrue(oracle.isValidCredential(CREDENTIAL_1));
    }
}
