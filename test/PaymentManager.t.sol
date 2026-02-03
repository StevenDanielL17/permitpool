// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PaymentManager, IYellowSession} from "../src/PaymentManager.sol";

/// @title PaymentManagerTest
/// @notice Comprehensive test suite for PaymentManager contract
contract PaymentManagerTest is Test {
    
    PaymentManager public paymentManager;
    MockYellowSession public yellowSession;
    
    address public admin = address(0x1);
    address public alice = address(0x2);
    
    bytes32 public constant LICENSE_NODE = keccak256("alice.fund.eth");
    bytes32 public constant SESSION_ID = keccak256("yellow-session-123");
    
    function setUp() public {
        yellowSession = new MockYellowSession();
        
        vm.prank(admin);
        paymentManager = new PaymentManager(address(yellowSession), admin);
    }
    
    // ============================================
    // DEPLOYMENT TESTS
    // ============================================
    
    function test_Deployment() public view {
        assertEq(paymentManager.admin(), admin);
        assertEq(address(paymentManager.yellowSession()), address(yellowSession));
    }
    
    function test_DeploymentRevertsWithZeroYellowSession() public {
        vm.expectRevert(PaymentManager.InvalidAddress.selector);
        new PaymentManager(address(0), admin);
    }
    
    function test_DeploymentRevertsWithZeroAdmin() public {
        vm.expectRevert(PaymentManager.InvalidAddress.selector);
        new PaymentManager(address(yellowSession), address(0));
    }
    
    // ============================================
    // SET PAYMENT SESSION TESTS
    // ============================================
    
    function test_SetPaymentSession_Success() public {
        vm.prank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
        
        assertEq(paymentManager.licensePayments(LICENSE_NODE), SESSION_ID);
        assertTrue(paymentManager.paymentRequired(LICENSE_NODE));
    }
    
    function test_SetPaymentSession_EmitsEvent() public {
        vm.expectEmit(true, true, false, false);
        emit PaymentManager.PaymentSessionLinked(LICENSE_NODE, SESSION_ID);
        
        vm.prank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
    }
    
    function test_SetPaymentSession_RevertsNonAdmin() public {
        vm.prank(alice);
        vm.expectRevert(PaymentManager.Unauthorized.selector);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
    }
    
    function test_SetPaymentSession_RevertsZeroLicense() public {
        vm.prank(admin);
        vm.expectRevert(PaymentManager.InvalidLicenseNode.selector);
        paymentManager.setPaymentSession(bytes32(0), SESSION_ID);
    }
    
    function test_SetPaymentSession_RevertsZeroSession() public {
        vm.prank(admin);
        vm.expectRevert(PaymentManager.InvalidSessionId.selector);
        paymentManager.setPaymentSession(LICENSE_NODE, bytes32(0));
    }
    
    // ============================================
    // UNLINK PAYMENT SESSION TESTS
    // ============================================
    
    function test_UnlinkPaymentSession_Success() public {
        vm.startPrank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
        paymentManager.unlinkPaymentSession(LICENSE_NODE);
        vm.stopPrank();
        
        assertEq(paymentManager.licensePayments(LICENSE_NODE), bytes32(0));
    }
    
    function test_UnlinkPaymentSession_EmitsEvent() public {
        vm.prank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
        
        vm.expectEmit(true, false, false, false);
        emit PaymentManager.PaymentSessionUnlinked(LICENSE_NODE);
        
        vm.prank(admin);
        paymentManager.unlinkPaymentSession(LICENSE_NODE);
    }
    
    // ============================================
    // PAYMENT REQUIREMENT TESTS
    // ============================================
    
    function test_SetPaymentRequirement_Success() public {
        vm.prank(admin);
        paymentManager.setPaymentRequirement(LICENSE_NODE, true);
        
        assertTrue(paymentManager.paymentRequired(LICENSE_NODE));
    }
    
    function test_SetPaymentRequirement_EmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit PaymentManager.PaymentRequirementChanged(LICENSE_NODE, true);
        
        vm.prank(admin);
        paymentManager.setPaymentRequirement(LICENSE_NODE, true);
    }
    
    // ============================================
    // PAYMENT ACTIVE TESTS
    // ============================================
    
    function test_IsPaymentActive_ReturnsTrueWhenNotRequired() public view {
        // Payment not required by default
        assertTrue(paymentManager.isPaymentActive(LICENSE_NODE));
    }
    
    function test_IsPaymentActive_ReturnsFalseWhenRequiredButNoSession() public {
        vm.prank(admin);
        paymentManager.setPaymentRequirement(LICENSE_NODE, true);
        
        assertFalse(paymentManager.isPaymentActive(LICENSE_NODE));
    }
    
    function test_IsPaymentActive_ReturnsTrueWhenSessionActive() public {
        // Set Yellow session as active
        yellowSession.setSessionActive(SESSION_ID, true);
        
        // Link session to license
        vm.prank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
        
        assertTrue(paymentManager.isPaymentActive(LICENSE_NODE));
    }
    
    function test_IsPaymentActive_ReturnsFalseWhenSessionExpired() public {
        // Set Yellow session as inactive
        yellowSession.setSessionActive(SESSION_ID, false);
        
        // Link session to license
        vm.prank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
        
        assertFalse(paymentManager.isPaymentActive(LICENSE_NODE));
    }
    
    // ============================================
    // REQUIRE ACTIVE PAYMENT TESTS
    // ============================================
    
    function test_RequireActivePayment_SucceedsWhenActive() public {
        yellowSession.setSessionActive(SESSION_ID, true);
        
        vm.prank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
        
        // Should not revert
        paymentManager.requireActivePayment(LICENSE_NODE);
    }
    
    function test_RequireActivePayment_RevertsWhenInactive() public {
        yellowSession.setSessionActive(SESSION_ID, false);
        
        vm.prank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
        
        vm.expectRevert(PaymentManager.PaymentOverdue.selector);
        paymentManager.requireActivePayment(LICENSE_NODE);
    }
    
    // ============================================
    // GET PAYMENT EXPIRY TESTS
    // ============================================
    
    function test_GetPaymentExpiry_ReturnsZeroWhenNotRequired() public view {
        assertEq(paymentManager.getPaymentExpiry(LICENSE_NODE), 0);
    }
    
    function test_GetPaymentExpiry_ReturnsExpiryFromYellow() public {
        uint256 expiry = block.timestamp + 30 days;
        yellowSession.setSessionExpiry(SESSION_ID, expiry);
        
        vm.prank(admin);
        paymentManager.setPaymentSession(LICENSE_NODE, SESSION_ID);
        
        assertEq(paymentManager.getPaymentExpiry(LICENSE_NODE), expiry);
    }
    
    // ============================================
    // ADMIN MANAGEMENT TESTS
    // ============================================
    
    function test_UpdateAdmin_Success() public {
        vm.prank(admin);
        paymentManager.updateAdmin(alice);
        
        assertEq(paymentManager.admin(), alice);
    }
    
    function test_UpdateAdmin_EmitsEvent() public {
        vm.expectEmit(true, true, false, false);
        emit PaymentManager.AdminUpdated(admin, alice);
        
        vm.prank(admin);
        paymentManager.updateAdmin(alice);
    }
    
    function test_UpdateAdmin_RevertsNonAdmin() public {
        vm.prank(alice);
        vm.expectRevert(PaymentManager.Unauthorized.selector);
        paymentManager.updateAdmin(address(0x999));
    }
}

// ============================================
// MOCK CONTRACTS
// ============================================

contract MockYellowSession is IYellowSession {
    mapping(bytes32 => bool) public activeStatus;
    mapping(bytes32 => uint256) public expiries;
    
    function setSessionActive(bytes32 sessionId, bool isActive) external {
        activeStatus[sessionId] = isActive;
    }
    
    function setSessionExpiry(bytes32 sessionId, uint256 expiry) external {
        expiries[sessionId] = expiry;
    }
    
    function isSessionActive(bytes32 sessionId) external view returns (bool isActive) {
        return activeStatus[sessionId];
    }
    
    function getSessionExpiry(bytes32 sessionId) external view returns (uint256 expiry) {
        return expiries[sessionId];
    }
}
