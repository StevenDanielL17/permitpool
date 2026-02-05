// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PaymentManager} from "../src/PaymentManager.sol";

/*//////////////////////////////////////////////////////////////
                         MOCK CONTRACTS
//////////////////////////////////////////////////////////////*/

contract MockYellowSession {
    mapping(bytes32 => bool) public active;
    mapping(bytes32 => uint256) public expiries;

    function setSession(bytes32 id, bool isActive, uint256 expiry) external {
        active[id] = isActive;
        expiries[id] = expiry;
    }

    function isSessionActive(bytes32 sessionId) external view returns (bool) {
        return active[sessionId];
    }
    
    function getSessionExpiry(bytes32 sessionId) external view returns (uint256) {
        return expiries[sessionId];
    }
}

/*//////////////////////////////////////////////////////////////
                         TEST CONTRACT
//////////////////////////////////////////////////////////////*/

contract PaymentManagerTest is Test {
    PaymentManager public manager;
    MockYellowSession public yellowSession;
    
    address public admin = address(0xAD);
    bytes32 public licenseNode = keccak256("license");
    bytes32 public sessionId = keccak256("session");
    
    event PaymentSessionLinked(bytes32 indexed licenseNode, bytes32 indexed yellowSessionId);
    event PaymentSessionUnlinked(bytes32 indexed licenseNode);
    event PaymentRequirementChanged(bytes32 indexed licenseNode, bool required);
    
    function setUp() public {
        vm.warp(100 days);
        yellowSession = new MockYellowSession();
        manager = new PaymentManager(address(yellowSession), admin);
    }
    
    function test_LinkSession() public {
        vm.prank(admin);
        vm.expectEmit(true, true, false, false);
        emit PaymentSessionLinked(licenseNode, sessionId);
        
        manager.setPaymentSession(licenseNode, sessionId);
        
        // Verify state
        assertTrue(manager.paymentRequired(licenseNode));
    }
    
    function test_IsPaymentActive() public {
        // Setup session in mock
        yellowSession.setSession(sessionId, true, block.timestamp + 1 days);
        
        // Link session
        vm.prank(admin);
        manager.setPaymentSession(licenseNode, sessionId);
        
        assertTrue(manager.isPaymentActive(licenseNode));
        
        // Disable session in mock
        yellowSession.setSession(sessionId, false, block.timestamp - 1 days);
        assertFalse(manager.isPaymentActive(licenseNode));
    }
    
    function test_IsPaymentActive_NoRequirement() public {
        // By default paymentRequired is false
        // Even without session, should be active (if not required)
        // Wait, current implementation:
        // if (!paymentRequired[licenseNode]) return true;
        assertTrue(manager.isPaymentActive(licenseNode));
    }
    
    function test_RequireActivePayment_RevertsAssumingRequired() public {
        // Setup session active = false
        yellowSession.setSession(sessionId, false, 0);
        
        vm.startPrank(admin);
        manager.setPaymentSession(licenseNode, sessionId);
        // Ensure it IS required
        manager.setPaymentRequirement(licenseNode, true);
        vm.stopPrank();
        
        vm.expectRevert(PaymentManager.PaymentOverdue.selector);
        manager.requireActivePayment(licenseNode);
    }
    
    function test_UnlinkSession() public {
        vm.prank(admin);
        manager.setPaymentSession(licenseNode, sessionId);
        
        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit PaymentSessionUnlinked(licenseNode);
        manager.unlinkPaymentSession(licenseNode);
        
        // Check state - should not strictly be deleted from paymentRequired depending on logic?
        // Logic: delete licensePayments[licenseNode].
        // Does NOT flip paymentRequired.
        // So checking isPaymentActive -> required=true. Session=0. Return false.
        
        assertFalse(manager.isPaymentActive(licenseNode));
    }
    
    function test_SetPaymentRequirement() public {
        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit PaymentRequirementChanged(licenseNode, false);
        manager.setPaymentRequirement(licenseNode, false);
        
        assertFalse(manager.paymentRequired(licenseNode));
    }
    
    function test_AdminReverts() public {
        vm.expectRevert(PaymentManager.Unauthorized.selector);
        manager.setPaymentSession(licenseNode, sessionId);
    }
}
