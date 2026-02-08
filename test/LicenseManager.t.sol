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

    function setFuses(bytes32 node, uint32 fuses) external {
        uint256 id = uint256(node);
        fuseData[id].fuses = fuseData[id].fuses | fuses;
    }

    function getData(uint256 id) external view returns (address owner, uint32 fuses, uint64 expiry) {
        FuseData memory data = fuseData[id];
        return (owners[id], data.fuses, data.expiry);
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

contract MockPermitPoolHook {
    mapping(address => bytes32) public userLicenseNode;
    
    function registerLicenseNode(address licensee, bytes32 node) external {
        userLicenseNode[licensee] = node;
    }
}

/*//////////////////////////////////////////////////////////////
                         TEST CONTRACT
//////////////////////////////////////////////////////////////*/

contract LicenseManagerTest is Test {
    LicenseManager public manager;
    MockNameWrapper public nameWrapper;
    MockResolver public resolver;
    MockPermitPoolHook public hook;
    
    address public admin = address(0xAD);
    address public user = address(0x1);
    bytes32 public parentNode = keccak256(abi.encodePacked(bytes32(0), keccak256("permitpool")));
    
    event LicenseIssued(address indexed holder, string subdomain, bytes32 indexed licenseNode, string arcCredential);
    
    function setUp() public {
        nameWrapper = new MockNameWrapper();
        resolver = new MockResolver();
        hook = new MockPermitPoolHook();
        
        vm.prank(admin);
        manager = new LicenseManager(
            address(nameWrapper),
            address(resolver),
            parentNode
        );
    }
    
    function test_IssueLicense() public {
        string memory label = "alice";
        string memory cred = "valid-cred";
        
        bytes32 expectedNode = keccak256(abi.encodePacked(parentNode, keccak256(bytes(label))));
        
        vm.prank(admin);
        vm.expectEmit(true, false, true, true);
        emit LicenseIssued(user, label, expectedNode, cred);
        
        bytes32 node = manager.issueLicense(user, label, cred);
        
        assertEq(node, expectedNode);
        assertEq(nameWrapper.ownerOf(uint256(node)), user);
        
        // Check resolver text
        assertEq(resolver.text(node, "arc.credential"), cred);
    }
    
    function test_IssueLicense_RevertsNonAdmin() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        manager.issueLicense(user, "bob", "cred");
    }
    
    function test_TransferOwnership() public {
        address newAdmin = address(0xBEEF);
        vm.prank(admin);
        manager.transferOwnership(newAdmin);
        
        // Verify new admin can issue
        vm.prank(newAdmin);
        manager.issueLicense(user, "charlie", "cred");
        
        // Verify old admin cannot
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", admin));
        manager.issueLicense(user, "dave", "cred");
    }
}
