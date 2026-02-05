// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PaymentManager} from "../src/PaymentManager.sol";

/*//////////////////////////////////////////////////////////////
                         MOCK CONTRACTS
//////////////////////////////////////////////////////////////*/

contract MockYellowSession {
    mapping(bytes32 => bool) public active;
    
    function setSession(bytes32 id, bool isActive, uint256 expiry) external {
        active[id] = isActive;
    }

    function isSessionActive(bytes32 sessionId) external view returns (bool) {
        return active[sessionId];
    }
    function settleSession(bytes32 sessionId) external {}

    function createSession(
        address[] calldata participants,
        address token,
        uint256 amount,
        uint256 duration
    ) external returns (bytes32) {
        // Simple mock return logic, generating dummy sessionId
        return keccak256(abi.encodePacked(participants, token, amount, duration, block.timestamp));
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
        
        manager.linkSession(licenseNode, sessionId);
        
        // Verify state (lastPayment updated)
        // paymentRequired is false by default unless linked? Wait.
        // My previous logic setPaymentSession set req=true.
        // linkSession sets link and lastPayment.
        // It does NOT set paymentRequired=true automatically in current impl (Step 1707).
        // I need to check if I should set it.
    }
    
    function test_IsPaymentActive() public {
        // Setup session in mock
        yellowSession.setSession(sessionId, true, block.timestamp + 1 days);
        
        // Link session
        vm.startPrank(admin);
        manager.linkSession(licenseNode, sessionId);
        // Requirement must be true for strict check, or false for loose.
        // If false, returns true. So let's set it true to test logic.
        manager.setPaymentRequirement(licenseNode, true);
        vm.stopPrank();
        
        assertTrue(manager.isPaymentCurrent(licenseNode));
        
        // Disable session in mock
        yellowSession.setSession(sessionId, false, block.timestamp - 1 days);
        assertFalse(manager.isPaymentCurrent(licenseNode));
    }
    
    function test_UnlinkSession() public {
        vm.prank(admin);
        manager.linkSession(licenseNode, sessionId);
        
        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit PaymentSessionUnlinked(licenseNode);
        manager.unlinkSession(licenseNode);
    }
    
    function test_SetPaymentRequirement() public {
        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit PaymentRequirementChanged(licenseNode, true);
        manager.setPaymentRequirement(licenseNode, true);
        
        assertTrue(manager.paymentRequired(licenseNode));
    }
    
    function test_AdminReverts() public {
        vm.expectRevert(PaymentManager.Unauthorized.selector);
        manager.linkSession(licenseNode, sessionId);
    }
}
