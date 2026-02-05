// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {LicenseManager} from "../src/LicenseManager.sol";

/*//////////////////////////////////////////////////////////////
                         MOCK CONTRACTS
//////////////////////////////////////////////////////////////*/

contract MockNameWrapper {
    mapping(uint256 => address) public owners;
    mapping(uint256 => FuseData) public fuseData;
    
    struct FuseData {
        address owner;
        uint32 fuses;
        uint64 expiry;
    }
    
    function setSubnodeOwner(
        bytes32 parentNode,
        string calldata label,
        address owner,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node) {
        node = keccak256(abi.encodePacked(parentNode, keccak256(bytes(label))));
        uint256 tokenId = uint256(node);
        
        owners[tokenId] = owner;
        fuseData[tokenId] = FuseData(owner, fuses, expiry);
        
        return node;
    }
    
    function ownerOf(uint256 id) external view returns (address) {
        return owners[id];
    }
}

contract MockResolver {
    mapping(bytes32 => mapping(string => string)) public textRecords;
    
    function setText(bytes32 node, string calldata key, string calldata value) external {
        textRecords[node][key] = value;
    }
    
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return textRecords[node][key];
    }
}

/*//////////////////////////////////////////////////////////////
                         TEST CONTRACT
//////////////////////////////////////////////////////////////*/

contract LicenseManagerTest is Test {
    LicenseManager public manager;
    MockNameWrapper public nameWrapper;
    MockResolver public resolver;
    
    address public admin = address(0xAD);
    address public user = address(0x1);
    bytes32 public parentNode = keccak256(abi.encodePacked(bytes32(0), keccak256("permitpool")));
    
    event LicenseIssued(address indexed licensee, string label, bytes32 indexed node, string arcCredentialHash);
    
    function setUp() public {
        nameWrapper = new MockNameWrapper();
        resolver = new MockResolver();
        
        manager = new LicenseManager(
            address(nameWrapper),
            address(resolver),
            parentNode,
            admin
        );
    }
    
    function test_IssueLicense() public {
        string memory label = "alice";
        string memory cred = "valid-cred";
        
        vm.prank(admin);
        vm.expectEmit(true, false, true, true); // label is not indexed
        // Note: event signature: event LicenseIssued(address indexed licensee, string label, bytes32 indexed node, string arcCredentialHash);
        
        bytes32 expectedNode = keccak256(abi.encodePacked(parentNode, keccak256(bytes(label))));
        emit LicenseIssued(user, label, expectedNode, cred);
        
        bytes32 node = manager.issueLicense(user, label, cred);
        
        assertEq(node, expectedNode);
        assertEq(nameWrapper.ownerOf(uint256(node)), user);
        
        // Check resolver text
        assertEq(resolver.text(node, "arc.credential"), cred);
    }
    
    function test_IssueLicense_RevertsNonAdmin() public {
        vm.prank(user);
        vm.expectRevert(LicenseManager.Unauthorized.selector);
        manager.issueLicense(user, "bob", "cred");
    }
    
    function test_IssueLicense_RevertsInvalidAddress() public {
        vm.prank(admin);
        vm.expectRevert(LicenseManager.InvalidAddress.selector);
        manager.issueLicense(address(0), "bob", "cred");
    }
    
    function test_IssueLicense_RevertsInvalidLabel() public {
        vm.prank(admin);
        vm.expectRevert(LicenseManager.InvalidLabel.selector);
        manager.issueLicense(user, "", "cred");
    }
    
    function test_IssueLicense_RevertsInvalidCredentialHash() public {
        vm.prank(admin);
        vm.expectRevert(LicenseManager.InvalidCredentialHash.selector);
        manager.issueLicense(user, "bob", "");
    }
    
    function test_UpdateAdmin() public {
        address newAdmin = address(0xBEEF);
        vm.prank(admin);
        manager.updateAdmin(newAdmin);
        
        // Verify new admin can issue
        vm.prank(newAdmin);
        manager.issueLicense(user, "charlie", "cred");
        
        // Verify old admin cannot
        vm.prank(admin);
        vm.expectRevert(LicenseManager.Unauthorized.selector);
        manager.issueLicense(user, "dave", "cred");
    }
}
