// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {MockArcOracle} from "../src/MockArcOracle.sol";

contract MockArcOracleTest is Test {
    MockArcOracle public oracle;
    address public admin = address(0xAD);
    address public user = address(0x1);
    
    event CredentialIssued(bytes32 indexed credentialHash, address indexed holder);
    event CredentialRevoked(bytes32 indexed credentialHash, address indexed holder);
    
    function setUp() public {
        oracle = new MockArcOracle(admin);
    }
    
    function test_IssueCredential() public {
        bytes32 credHash = keccak256("valid-hash");
        
        vm.prank(admin);
        vm.expectEmit(true, true, false, false);
        emit CredentialIssued(credHash, user);
        
        oracle.issueCredential(credHash, user);
        
        assertTrue(oracle.isValidCredential(credHash));
        assertTrue(oracle.validCredentials(credHash));
    }
    
    function test_RevokeCredential() public {
        bytes32 credHash = keccak256("valid-hash");
        
        vm.prank(admin);
        oracle.issueCredential(credHash, user);
        
        vm.prank(admin);
        vm.expectEmit(true, true, false, false);
        emit CredentialRevoked(credHash, user);
        oracle.revokeCredential(credHash, user);
        
        assertFalse(oracle.isValidCredential(credHash));
    }
    
    function test_AdminChecks() public {
        bytes32 credHash = keccak256("valid-hash");
        vm.prank(user);
        vm.expectRevert(MockArcOracle.Unauthorized.selector);
        oracle.issueCredential(credHash, user);
    }
}
