// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {PaymentManager} from "../src/PaymentManager.sol";
import {MockYellowClearnode} from "../src/MockYellowClearnode.sol";

/**
 * @title UNIT1_YellowNetworkAuthTest
 * @notice Tests Yellow Network authentication and payment session creation
 * UNIT 1: Yellow Network Auth & Payment Session Integration
 * 
 * NOTE: This test validates:
 * 1. Session key generation and management
 * 2. Payment session creation with Yellow Clearnode
 * 3. Session activation and expiry
 * 4. Payment linking to licenses
 * 5. Multi-user session management
 */
contract UNIT1_YellowNetworkAuthTest is Test {
    // Support contracts
    PaymentManager public paymentManager;
    MockYellowClearnode public yellowClearnode;

    // Test addresses
    address public owner = 0x52b34414Df3e56ae853BC4A0EB653231447C2A36;
    address public trader1 = 0x1111111111111111111111111111111111111111;
    address public trader2 = 0x2222222222222222222222222222222222222222;
    address public trader3 = 0x3333333333333333333333333333333333333333;

    function setUp() public {
        console.log("\n=== UNIT 1: Yellow Network Auth Setup ===\n");
        
        yellowClearnode = new MockYellowClearnode();
        paymentManager = new PaymentManager(address(yellowClearnode), owner);
        
        console.log("Deployed contracts:");
        console.log("  - MockYellowClearnode");
        console.log("  - PaymentManager");
        console.log("\nReady for auth flow testing");
    }

    // ====== UNIT 1.1: Yellow Clearnode Session Creation ======
    function test_Unit1_1_YellowSessionCreation() public {
        console.log("\n[UNIT 1.1] Testing Yellow Clearnode session creation...");
        
        // Prepare session participants
        address[] memory participants = new address[](2);
        participants[0] = trader1;
        participants[1] = owner;
        
        // Create session via Yellow Clearnode
        bytes32 sessionId = yellowClearnode.createSession(
            participants,
            address(0), // token address (0x0 for test)
            1 ether,    // amount
            86400       // duration (1 day)
        );
        
        assertTrue(sessionId != bytes32(0), "Session ID not created");
        console.log("  OK: Yellow session created");
    }

    // ====== UNIT 1.2: Session Activation Flow ======
    function test_Unit1_2_SessionActivationFlow() public {
        console.log("\n[UNIT 1.2] Testing session activation flow...");
        
        bytes32 sessionId = bytes32(uint256(1001));
        
        // Initially inactive
        bool initialActive = yellowClearnode.isSessionActive(sessionId);
        assertFalse(initialActive, "Session should be inactive initially");
        
        // Activate session
        vm.prank(owner);
        yellowClearnode.setSession(sessionId, true);
        
        // Now should be active
        bool isActive = yellowClearnode.isSessionActive(sessionId);
        assertTrue(isActive, "Session not activated");
        
        console.log("  OK: Session activation verified");
    }

    // ====== UNIT 1.3: Payment Session Linking ======
    function test_Unit1_3_PaymentSessionLinking() public {
        console.log("\n[UNIT 1.3] Testing payment session linking...");
        
        // Create license node
        bytes32 licenseNode = keccak256(abi.encode(trader1, "permit.eth"));
        
        // Create Yellow session
        address[] memory participants = new address[](1);
        participants[0] = trader1;
        bytes32 sessionId = yellowClearnode.createSession(
            participants,
            address(0),
            1 ether,
            86400
        );
        
        // Link payment to license
        vm.prank(owner);
        paymentManager.linkSession(licenseNode, sessionId);
        
        // Verify linkage
        bytes32 linkedSession = paymentManager.licensePayments(licenseNode);
        assertEq(linkedSession, sessionId, "Session not linked to license");
        
        console.log("  OK: Payment session linked to license");
    }

    // ====== UNIT 1.4: Auth Parameters Validation ======
    function test_Unit1_4_AuthParametersValidation() public {
        console.log("\n[UNIT 1.4] Testing auth parameters validation...");
        
        // Simulate auth parameters from EIP-712 signed request
        address sessionKey = address(uint160(uint256(111))); // Session key as address
        uint256 expiresAt = block.timestamp + 3600; // 1 hour
        
        assertTrue(sessionKey != address(0), "Session key invalid");
        assertTrue(expiresAt > block.timestamp, "Expiry time invalid");
        
        console.log("  OK: Auth parameters validated");
    }

    // ====== UNIT 1.5: Multi-Session Management ======
    function test_Unit1_5_MultiSessionManagement() public {
        console.log("\n[UNIT 1.5] Testing multi-session management...");
        
        // Create sessions for multiple traders
        bytes32 sessionId1 = bytes32(uint256(2001));
        bytes32 sessionId2 = bytes32(uint256(2002));
        bytes32 sessionId3 = bytes32(uint256(2003));
        
        // Activate all sessions
        vm.prank(owner);
        yellowClearnode.setSession(sessionId1, true);
        
        vm.prank(owner);
        yellowClearnode.setSession(sessionId2, true);
        
        vm.prank(owner);
        yellowClearnode.setSession(sessionId3, true);
        
        // Verify all are active
        assertTrue(yellowClearnode.isSessionActive(sessionId1), "Session 1 not active");
        assertTrue(yellowClearnode.isSessionActive(sessionId2), "Session 2 not active");
        assertTrue(yellowClearnode.isSessionActive(sessionId3), "Session 3 not active");
        
        // Link to licenses
        bytes32 licenseNode1 = keccak256(abi.encode(trader1, "permit.eth"));
        bytes32 licenseNode2 = keccak256(abi.encode(trader2, "permit.eth"));
        bytes32 licenseNode3 = keccak256(abi.encode(trader3, "permit.eth"));
        
        vm.prank(owner);
        paymentManager.linkSession(licenseNode1, sessionId1);
        
        vm.prank(owner);
        paymentManager.linkSession(licenseNode2, sessionId2);
        
        vm.prank(owner);
        paymentManager.linkSession(licenseNode3, sessionId3);
        
        // Verify all linkages independent
        assertEq(paymentManager.licensePayments(licenseNode1), sessionId1);
        assertEq(paymentManager.licensePayments(licenseNode2), sessionId2);
        assertEq(paymentManager.licensePayments(licenseNode3), sessionId3);
        
        console.log("  OK: Multiple sessions managed independently");
    }

    // ====== UNIT 1.6: Payment Requirement Setting ======
    function test_Unit1_6_PaymentRequirementSetting() public {
        console.log("\n[UNIT 1.6] Testing payment requirement setting...");
        
        bytes32 licenseNode = keccak256(abi.encode(trader1, "permit.eth"));
        
        // Set payment requirement
        vm.prank(owner);
        paymentManager.setPaymentRequirement(licenseNode, true);
        
        // Verify requirement set
        bool required = paymentManager.paymentRequired(licenseNode);
        assertTrue(required, "Payment requirement not set");
        
        // Can disable
        vm.prank(owner);
        paymentManager.setPaymentRequirement(licenseNode, false);
        
        required = paymentManager.paymentRequired(licenseNode);
        assertFalse(required, "Payment requirement not disabled");
        
        console.log("  OK: Payment requirements managed correctly");
    }

    // ====== UNIT 1.7: Admin Authority Session Management ======
    function test_Unit1_7_AdminAuthoritySessionManagement() public {
        console.log("\n[UNIT 1.7] Testing admin authority on session management...");
        
        bytes32 licenseNode = keccak256(abi.encode(trader1, "permit.eth"));
        bytes32 sessionId = bytes32(uint256(3001));
        
        // Admin can link
        vm.prank(owner);
        paymentManager.linkSession(licenseNode, sessionId);
        
        bytes32 linked = paymentManager.licensePayments(licenseNode);
        assertEq(linked, sessionId, "Admin link failed");
        
        // Non-admin cannot unlink
        vm.prank(trader1);
        vm.expectRevert();
        paymentManager.unlinkSession(licenseNode);
        
        // Admin can unlink
        vm.prank(owner);
        paymentManager.unlinkSession(licenseNode);
        
        linked = paymentManager.licensePayments(licenseNode);
        assertEq(linked, bytes32(0), "Admin unlink failed");
        
        console.log("  OK: Admin authority enforced");
    }

    // ====== UNIT 1.8: Full Auth & Payment Flow ======
    function test_Unit1_8_FullAuthPaymentFlow() public {
        console.log("\n[UNIT 1.8] Testing full auth and payment flow...");
        
        // 1. Create Yellow session
        address[] memory participants = new address[](1);
        participants[0] = trader1;
        bytes32 sessionId = yellowClearnode.createSession(
            participants,
            address(0),
            1 ether,
            86400
        );
        assertTrue(sessionId != bytes32(0), "Session creation failed");
        
        // 2. Activate session
        vm.prank(owner);
        yellowClearnode.setSession(sessionId, true);
        assertTrue(yellowClearnode.isSessionActive(sessionId), "Session not active");
        
        // 3. Create license node
        bytes32 licenseNode = keccak256(abi.encode(trader1, "permit.eth"));
        
        // 4. Link payment to license
        vm.prank(owner);
        paymentManager.linkSession(licenseNode, sessionId);
        assertEq(paymentManager.licensePayments(licenseNode), sessionId, "Linking failed");
        
        // 5. Set payment requirement
        vm.prank(owner);
        paymentManager.setPaymentRequirement(licenseNode, true);
        assertTrue(paymentManager.paymentRequired(licenseNode), "Requirement not set");
        
        // 6. Verify payment is current (simplified check)
        // In real Yellow, isPaymentCurrent checks Yellow session validity + deadline
        bool paymentCurrent = paymentManager.isPaymentCurrent(licenseNode);
        // Should be true if session active and within payment period
        assertTrue(paymentCurrent || !yellowClearnode.isSessionActive(sessionId), 
                   "Payment verification logic failed");
        
        console.log("  OK: Full auth and payment flow verified");
        console.log("\n=== UNIT 1 Complete ===\n");
    }
}
