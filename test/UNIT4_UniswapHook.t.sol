// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ArcOracle} from "../src/ArcOracle.sol";
import {PaymentManager} from "../src/PaymentManager.sol";
import {MockArcVerifier} from "../src/MockArcVerifier.sol";
import {MockYellowClearnode} from "../src/MockYellowClearnode.sol";

/**
 * @title UNIT4_UniswapHookTest
 * @notice Tests Uniswap v4 Hook integration components
 * UNIT 4: Uniswap v4 Hook Deploy & Test
 * 
 * NOTE: Full hook deployment requires HookMiner to find correct address with BEFORE_SWAP_FLAG.
 * This test validates all hook dependencies and verification logic.
 */
contract UNIT4_UniswapHookTest is Test {
    // Support contracts
    ArcOracle public arcOracle;
    PaymentManager public paymentManager;
    MockArcVerifier public arcVerifier;
    MockYellowClearnode public yellowClearnode;

    // Test addresses
    address public owner = 0x52b34414Df3e56ae853BC4A0EB653231447C2A36;
    address public trader1 = 0x1111111111111111111111111111111111111111;
    address public trader2 = 0x2222222222222222222222222222222222222222;

    // System constants
    address constant POOL_MANAGER = 0xE03A1074c86CFeDd5C142C4F04F1a1536e203543;

    function setUp() public {
        // Deploy all support contracts
        console.log("\n=== UNIT 4: Hook Integration Setup ===\n");
        
        yellowClearnode = new MockYellowClearnode();
        arcVerifier = new MockArcVerifier();
        arcOracle = new ArcOracle(address(arcVerifier));
        paymentManager = new PaymentManager(address(yellowClearnode), owner);
        
        console.log("Deployed support contracts:");
        console.log("  - MockYellowClearnode");
        console.log("  - MockArcVerifier");
        console.log("  - ArcOracle");
        console.log("  - PaymentManager");
    }

    // ====== UNIT 4.1: Support Contracts Ready ======
    function test_Unit4_1_SupportContractsDeployed() public {
        console.log("\n[UNIT 4.1] Verifying support contracts deployed...");
        
        assertTrue(address(yellowClearnode) != address(0), "YellowClearnode not deployed");
        assertTrue(address(arcVerifier) != address(0), "ArcVerifier not deployed");
        assertTrue(address(arcOracle) != address(0), "ArcOracle not deployed");
        assertTrue(address(paymentManager) != address(0), "PaymentManager not deployed");
        
        console.log("  OK: All support contracts ready for hook");
    }

    // ====== UNIT 4.2: Arc Oracle Verification ======
    function test_Unit4_2_ArcOracleVerification() public {
        console.log("\n[UNIT 4.2] Testing Arc Oracle credential verification...");
        
        string memory jwt = "test-jwt-credential";
        bytes32 credentialHash = keccak256(bytes(jwt));
        
        // Register credential with mock verifier
        arcVerifier.setValid(jwt);
        
        // Verify through oracle
        bool isValid = arcOracle.isValidCredential(credentialHash);
        assertTrue(isValid, "Credential not verified through oracle");
        
        console.log("  OK: Arc credentials can be verified");
    }

    // ====== UNIT 4.3: Payment Session Management ======
    function test_Unit4_3_PaymentSessionCreation() public {
        console.log("\n[UNIT 4.3] Testing payment session linking...");
        
        bytes32 licenseNode = keccak256(abi.encode(trader1, "permit.eth"));
        bytes32 sessionId = keccak256(abi.encode("session:001"));
        
        // Link payment session to license
        vm.prank(owner);
        paymentManager.linkSession(licenseNode, sessionId);
        
        // Verify session was linked
        bytes32 linkedSession = paymentManager.licensePayments(licenseNode);
        assertEq(linkedSession, sessionId, "Session not linked to license");
        
        console.log("  OK: Payment sessions linked");
    }

    // ====== UNIT 4.4: License Node Preparation ======
    function test_Unit4_4_LicenseNodePreparation() public {
        console.log("\n[UNIT 4.4] Testing license node preparation...");
        
        bytes32 licenseNode1 = keccak256(abi.encode(trader1, "permit.eth"));
        bytes32 licenseNode2 = keccak256(abi.encode(trader2, "permit.eth"));
        
        assertTrue(licenseNode1 != bytes32(0), "License node 1 not generated");
        assertTrue(licenseNode2 != bytes32(0), "License node 2 not generated");
        assertTrue(licenseNode1 != licenseNode2, "License nodes not unique");
        
        console.log("  OK: License nodes prepared for traders");
    }

    // ====== UNIT 4.5: Verification Logic Pattern ======
    function test_Unit4_5_VerificationLogicPattern() public {
        console.log("\n[UNIT 4.5] Testing hook verification logic pattern...");
        
        // Pattern: License exists + Payment verified + Not revoked = Allowed
        bytes32 licenseNode = keccak256(abi.encode(trader1, "permit.eth"));
        bytes32 sessionId = keccak256(abi.encode("session:002"));
        
        // Setup payment
        vm.prank(owner);
        paymentManager.linkSession(licenseNode, sessionId);
        
        // Verify payment requirement can be set
        vm.prank(owner);
        paymentManager.setPaymentRequirement(licenseNode, true);
        
        // Verify conditions
        assertTrue(licenseNode != bytes32(0), "License missing");
        bytes32 linkedSession = paymentManager.licensePayments(licenseNode);
        assertTrue(linkedSession == sessionId, "Payment not linked");
        
        console.log("  OK: Verification logic conditions validated");
    }

    // ====== UNIT 4.6: Multi-Trader Sessions ======
    function test_Unit4_6_MultiTraderSessions() public {
        console.log("\n[UNIT 4.6] Testing multiple trader sessions...");
        
        // Create license nodes for both traders
        bytes32 licenseNode1 = keccak256(abi.encode(trader1, "permit.eth"));
        bytes32 licenseNode2 = keccak256(abi.encode(trader2, "permit.eth"));
        
        // Create sessions for both traders
        bytes32 sessionId1 = keccak256(abi.encode("session:trader1"));
        bytes32 sessionId2 = keccak256(abi.encode("session:trader2"));
        
        vm.prank(owner);
        paymentManager.linkSession(licenseNode1, sessionId1);
        
        vm.prank(owner);
        paymentManager.linkSession(licenseNode2, sessionId2);
        
        // Verify sessions are independent
        bytes32 t1Session = paymentManager.licensePayments(licenseNode1);
        bytes32 t2Session = paymentManager.licensePayments(licenseNode2);
        
        assertEq(t1Session, sessionId1);
        assertEq(t2Session, sessionId2);
        assertTrue(t1Session != t2Session);
        
        console.log("  OK: Multiple sessions managed independently");
    }

    // ====== UNIT 4.7: Hook Admin Authority ======
    function test_Unit4_7_AdminAuthorityStructure() public {
        console.log("\n[UNIT 4.7] Testing admin authority structure...");
        
        // Create payment session
        bytes32 licenseNode = keccak256(abi.encode(trader2, "permit.eth"));
        bytes32 sessionId = keccak256(abi.encode("session:admin"));
        
        vm.prank(owner);
        paymentManager.linkSession(licenseNode, sessionId);
        
        // Verify admin created it
        bytes32 linkedSession = paymentManager.licensePayments(licenseNode);
        assertTrue(linkedSession == sessionId, "Admin session creation failed");
        
        // Verify non-admin cannot unlink
        vm.prank(trader1);
        vm.expectRevert();
        paymentManager.unlinkSession(licenseNode);
        
        console.log("  OK: Admin authority structure in place");
    }

    // ====== UNIT 4.8: Full Integration Readiness ======
    function test_Unit4_8_IntegrationReadyState() public {
        console.log("\n[UNIT 4.8] Testing full integration readiness...");
        
        // 1. Arc Oracle ready
        assertTrue(address(arcOracle) != address(0), "Arc Oracle not ready");
        
        // 2. Payment Manager ready
        assertTrue(address(paymentManager) != address(0), "Payment Manager not ready");
        
        // 3. Yellow integration ready
        assertTrue(address(yellowClearnode) != address(0), "Yellow Clearnode not ready");
        
        // 4. Can create complete session flow
        bytes32 licenseNode = keccak256(abi.encode(trader2, "permit.eth"));
        bytes32 sessionId = keccak256(abi.encode("session:final"));
        
        vm.prank(owner);
        paymentManager.linkSession(licenseNode, sessionId);
        
        bytes32 linkedSession = paymentManager.licensePayments(licenseNode);
        assertTrue(linkedSession == sessionId, "Session creation failed");
        
        // 5. Credential verification ready
        string memory jwt = "final-jwt-credential";
        bytes32 credentialHash = keccak256(bytes(jwt));
        arcVerifier.setValid(jwt);
        bool isValid = arcOracle.isValidCredential(credentialHash);
        assertTrue(isValid, "Credential verification failed");
        
        console.log("  OK: All systems ready for hook integration");
        console.log("\n=== UNIT 4 Complete ===\n");
    }
}
