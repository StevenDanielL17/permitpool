// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PermitPoolHook} from "../src/PermitPoolHook.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";

/*//////////////////////////////////////////////////////////////
                         MOCK CONTRACTS
//////////////////////////////////////////////////////////////*/

/// @notice Mock ENS Name Wrapper for testing
contract MockNameWrapper {
    // Mapping: address => ENS name
    mapping(address => bytes) public names;
    
    // Mapping: node => owner
    mapping(uint256 => address) public owners;
    
    // Mapping: node => fuse data
    mapping(uint256 => FuseData) public fuseData;
    
    struct FuseData {
        address owner;
        uint32 fuses;
        uint64 expiry;
    }
    
    function setName(address addr, string memory name) external {
        names[addr] = bytes(name);
    }
    
    function setOwner(uint256 node, address owner) external {
        owners[node] = owner;
        fuseData[node].owner = owner;
    }
    
    function setFuses(uint256 node, uint32 fuses) external {
        fuseData[node].fuses = fuses;
    }
    
    function ownerOf(uint256 id) external view returns (address) {
        return owners[id];
    }
    
    function getData(uint256 id) external view returns (address owner, uint32 fuses, uint64 expiry) {
        FuseData memory data = fuseData[id];
        return (data.owner, data.fuses, data.expiry);
    }
}

/// @notice Mock ENS Text Resolver for testing
contract MockTextResolver {
    // Mapping: node => key => value
    mapping(bytes32 => mapping(string => string)) public textRecords;
    
    function setText(bytes32 node, string memory key, string memory value) external {
        textRecords[node][key] = value;
    }
    
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return textRecords[node][key];
    }
}

/// @notice Mock Pool Manager for testing
contract MockPoolManager {
    // Minimal implementation just to satisfy the hook
}

/*//////////////////////////////////////////////////////////////
                         TEST CONTRACT
//////////////////////////////////////////////////////////////*/

contract PermitPoolHookTest is Test {
    PermitPoolHook public hook;
    MockNameWrapper public nameWrapper;
    MockTextResolver public textResolver;
    MockPoolManager public poolManager;
    
    // Test addresses
    address public admin = address(0xAD);
    address public validUser = address(0x1);
    address public invalidUser = address(0x2);
    
    // ENS constants
    bytes32 public parentNode = keccak256(abi.encodePacked(bytes32(0), keccak256("permitpool")));
    uint32 public constant CANNOT_TRANSFER = 0x4;
    uint32 public constant PARENT_CANNOT_CONTROL = 0x10000;
    uint256 public validNode;
    
    function setUp() public {
        // Deploy mock contracts
        nameWrapper = new MockNameWrapper();
        textResolver = new MockTextResolver();
        poolManager = new MockPoolManager();
        
        // Deploy hook
        hook = new PermitPoolHook(
            IPoolManager(address(poolManager)),
            address(nameWrapper),
            address(textResolver),
            parentNode,
            admin
        );
        
        // Compute valid node for "alice.permitpool.eth"
        // eth = keccak256(0x00 + keccak256("eth"))
        bytes32 ethNode = keccak256(abi.encodePacked(bytes32(0), keccak256("eth")));
        // permitpool.eth = keccak256(ethNode + keccak256("permitpool"))
        bytes32 permitpoolNode = keccak256(abi.encodePacked(ethNode, keccak256("permitpool")));
        // alice.permitpool.eth = keccak256(permitpoolNode + keccak256("alice"))
        validNode = uint256(keccak256(abi.encodePacked(permitpoolNode, keccak256("alice"))));
        
        // Setup valid user with proper ENS, fuses, and credential
        nameWrapper.setName(validUser, "alice.permitpool.eth");
        nameWrapper.setOwner(validNode, validUser);
        nameWrapper.setFuses(validNode, CANNOT_TRANSFER | PARENT_CANNOT_CONTROL);
        textResolver.setText(bytes32(validNode), "arc.credential", "valid_arc_credential");
    }
    
    /*//////////////////////////////////////////////////////////////
                         DEPLOYMENT TESTS
    //////////////////////////////////////////////////////////////*/
    
    function test_Deployment() public {
        assertEq(address(hook.nameWrapper()), address(nameWrapper));
        assertEq(address(hook.textResolver()), address(textResolver));
        assertEq(hook.parentNode(), parentNode);
        assertEq(hook.admin(), admin);
    }
    
    function test_DeploymentRevertsWithZeroNameWrapper() public {
        vm.expectRevert(PermitPoolHook.InvalidAddress.selector);
        new PermitPoolHook(
            IPoolManager(address(poolManager)),
            address(0),
            address(textResolver),
            parentNode,
            admin
        );
    }
    
    function test_DeploymentRevertsWithZeroTextResolver() public {
        vm.expectRevert(PermitPoolHook.InvalidAddress.selector);
        new PermitPoolHook(
            IPoolManager(address(poolManager)),
            address(nameWrapper),
            address(0),
            parentNode,
            admin
        );
    }
    
    function test_DeploymentRevertsWithZeroAdmin() public {
        vm.expectRevert(PermitPoolHook.InvalidAddress.selector);
        new PermitPoolHook(
            IPoolManager(address(poolManager)),
            address(nameWrapper),
            address(textResolver),
            parentNode,
            address(0)
        );
    }
    
    /*//////////////////////////////////////////////////////////////
                       BEFORESWAP HAPPY PATH
    //////////////////////////////////////////////////////////////*/
    
    function test_BeforeSwap_ValidUser() public {
        // This should NOT revert
        (bytes4 selector,,) = hook.beforeSwap(
            validUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
        
        // Should return correct selector
        assertEq(selector, hook.beforeSwap.selector);
    }
    
    /*//////////////////////////////////////////////////////////////
                       ENS VERIFICATION TESTS
    //////////////////////////////////////////////////////////////*/
    
    function test_BeforeSwap_RevertsNoENSName() public {
        vm.expectRevert(abi.encodeWithSelector(PermitPoolHook.NoENSSubdomain.selector, invalidUser));
        hook.beforeSwap(
            invalidUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    function test_BeforeSwap_RevertsWrongParent() public {
        address wrongParentUser = address(0x3);
        // Set up user with name under different parent (e.g., just "alice.eth")
        nameWrapper.setName(wrongParentUser, "alice.eth");
        
        vm.expectRevert(abi.encodeWithSelector(PermitPoolHook.NoENSSubdomain.selector, wrongParentUser));
        hook.beforeSwap(
            wrongParentUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    /*//////////////////////////////////////////////////////////////
                         FUSE VERIFICATION TESTS
    //////////////////////////////////////////////////////////////*/
    
    function test_BeforeSwap_RevertsInvalidFuses_MissingCannotTransfer() public {
        address noTransferFuseUser = address(0x4);
        uint256 node = uint256(keccak256("testnode1"));
        
        nameWrapper.setName(noTransferFuseUser, "bob.permitpool.eth");
        nameWrapper.setOwner(node, noTransferFuseUser);
        // Only PARENT_CANNOT_CONTROL, missing CANNOT_TRANSFER
        nameWrapper.setFuses(node, PARENT_CANNOT_CONTROL);
        textResolver.setText(bytes32(node), "arc.credential", "valid");
        
        vm.expectRevert(abi.encodeWithSelector(PermitPoolHook.InvalidFuses.selector, noTransferFuseUser, PARENT_CANNOT_CONTROL));
        hook.beforeSwap(
            noTransferFuseUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    function test_BeforeSwap_RevertsInvalidFuses_MissingParentControl() public {
        address noParentControlUser = address(0x5);
        uint256 node = uint256(keccak256("testnode2"));
        
        nameWrapper.setName(noParentControlUser, "charlie.permitpool.eth");
        nameWrapper.setOwner(node, noParentControlUser);
        // Only CANNOT_TRANSFER, missing PARENT_CANNOT_CONTROL
        nameWrapper.setFuses(node, CANNOT_TRANSFER);
        textResolver.setText(bytes32(node), "arc.credential", "valid");
        
        vm.expectRevert(abi.encodeWithSelector(PermitPoolHook.InvalidFuses.selector, noParentControlUser, CANNOT_TRANSFER));
        hook.beforeSwap(
            noParentControlUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    /*//////////////////////////////////////////////////////////////
                     ARC CREDENTIAL TESTS
    //////////////////////////////////////////////////////////////*/
    
    function test_BeforeSwap_RevertsNoArcCredential() public {
        address noCredentialUser = address(0x6);
        
        nameWrapper.setName(noCredentialUser, "dave.permitpool.eth");
        nameWrapper.setOwner(validNode, noCredentialUser);
        nameWrapper.setFuses(validNode, CANNOT_TRANSFER | PARENT_CANNOT_CONTROL);
        // NO Arc credential set
        
        vm.expectRevert(abi.encodeWithSelector(PermitPoolHook.NoArcCredential.selector, noCredentialUser));
        hook.beforeSwap(
            noCredentialUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    /*//////////////////////////////////////////////////////////////
                       REVOCATION TESTS
    //////////////////////////////////////////////////////////////*/
    
    function test_RevokeLicense_ByAdmin() public {
        vm.prank(admin);
        hook.revokeLicense(validUser);
        
        assertTrue(hook.revokedLicenses(validUser));
    }
    
    function test_RevokeLicense_RevertsNonAdmin() public {
        vm.prank(invalidUser);
        vm.expectRevert(PermitPoolHook.Unauthorized.selector);
        hook.revokeLicense(validUser);
    }
    
    function test_BeforeSwap_RevertsRevokedLicense() public {
        // Revoke license
        vm.prank(admin);
        hook.revokeLicense(validUser);
        
        // Try to swap
        vm.expectRevert(abi.encodeWithSelector(PermitPoolHook.LicenseRevoked.selector, validUser));
        hook.beforeSwap(
            validUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    function test_RestoreLicense_ByAdmin() public {
        // First revoke
        vm.prank(admin);
        hook.revokeLicense(validUser);
        
        // Then restore
        vm.prank(admin);
        hook.restoreLicense(validUser);
        
        assertFalse(hook.revokedLicenses(validUser));
        
        // Should be able to swap again
        hook.beforeSwap(
            validUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    function test_RestoreLicense_RevertsNonAdmin() public {
        vm.prank(invalidUser);
        vm.expectRevert(PermitPoolHook.Unauthorized.selector);
        hook.restoreLicense(validUser);
    }
    
    /*//////////////////////////////////////////////////////////////
                       ADMIN MANAGEMENT TESTS
    //////////////////////////////////////////////////////////////*/
    
    function test_UpdateAdmin_ByAdmin() public {
        address newAdmin = address(0xBEEF);
        
        vm.prank(admin);
        hook.updateAdmin(newAdmin);
        
        assertEq(hook.admin(), newAdmin);
    }
    
    function test_UpdateAdmin_RevertsNonAdmin() public {
        vm.prank(invalidUser);
        vm.expectRevert(PermitPoolHook.Unauthorized.selector);
        hook.updateAdmin(invalidUser);
    }
    
    function test_UpdateAdmin_RevertsZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(PermitPoolHook.InvalidAddress.selector);
        hook.updateAdmin(address(0));
    }
    
    /*//////////////////////////////////////////////////////////////
                          EVENT TESTS
    //////////////////////////////////////////////////////////////*/
    
    function test_LicenseChecked_Event() public {
        vm.expectEmit(true, true, false, true);
        emit PermitPoolHook.LicenseChecked(validUser, bytes32(validNode), true);
        
        hook.beforeSwap(
            validUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    function test_LicenseRevoked_Event() public {
        vm.expectEmit(true, true, false, true);
        emit PermitPoolHook.LicenseRevokedEvent(validUser, bytes32(validNode));
        
        vm.prank(admin);
        hook.revokeLicense(validUser);
    }
    
    function test_LicenseRestored_Event() public {
        // First revoke
        vm.prank(admin);
        hook.revokeLicense(validUser);
        
        // Then expect restore event
        vm.expectEmit(true, false, false, false);
        emit PermitPoolHook.LicenseRestored(validUser);
        
        vm.prank(admin);
        hook.restoreLicense(validUser);
    }
    
    function test_AdminUpdated_Event() public {
        address newAdmin = address(0xBEEF);
        
        vm.expectEmit(true, true, false, false);
        emit PermitPoolHook.AdminUpdated(admin, newAdmin);
        
        vm.prank(admin);
        hook.updateAdmin(newAdmin);
    }
}
