// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PermitPoolHook} from "../src/PermitPoolHook.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {HookMiner} from "v4-periphery/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";

import {MockArcVerifier} from "../src/MockArcVerifier.sol";
import {MockYellowClearnode} from "../src/MockYellowClearnode.sol";
import {ArcOracle} from "../src/ArcOracle.sol";
import {PaymentManager} from "../src/PaymentManager.sol";

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
    
    function setFuses(bytes32 node, uint32 fuses) external {
        fuseData[uint256(node)].fuses = fuses;
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
    MockArcVerifier public arcVerifier;
    MockYellowClearnode public clearnode;
    
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
        
        // Compute valid node for "alice.permitpool.eth"
        bytes32 ethNode = keccak256(abi.encodePacked(bytes32(0), keccak256("eth")));
        bytes32 permitpoolNode = keccak256(abi.encodePacked(ethNode, keccak256("permitpool")));
        parentNode = permitpoolNode;

        // Deploy Mocks
        arcVerifier = new MockArcVerifier();
        ArcOracle arcOracle = new ArcOracle(address(arcVerifier));
        clearnode = new MockYellowClearnode();
        PaymentManager paymentManager = new PaymentManager(address(clearnode), admin);

        // Deploy hook
        hook = mineAndDeploy(
            address(poolManager),
            address(nameWrapper),
            address(textResolver),
            parentNode,
            admin,
            address(arcOracle),
            address(paymentManager)
        );
        
        // alice.permitpool.eth
        validNode = uint256(keccak256(abi.encodePacked(permitpoolNode, keccak256("alice"))));
        
        // Setup valid user
        nameWrapper.setName(validUser, "alice.permitpool.eth");
        nameWrapper.setOwner(validNode, validUser);
        nameWrapper.setFuses(bytes32(validNode), CANNOT_TRANSFER | PARENT_CANNOT_CONTROL);
        textResolver.setText(bytes32(validNode), "arc.credential", "valid_arc_credential");
        
        // Setup Arc and Yellow Logic
        arcVerifier.setValid("valid_arc_credential");
        
        // Setup Yellow
        bytes32 licenseNode = bytes32(validNode);
        bytes32 sessionId = keccak256("valid_session");
        clearnode.setSession(sessionId, true);
        
        // Explicitly use the paymentManager address we know, although hook.paymentManager() should be same
        vm.startPrank(admin);
        paymentManager.linkSession(licenseNode, sessionId);
        paymentManager.setPaymentRequirement(licenseNode, true);
        vm.stopPrank();
    }

    // Helper to mine salt and deploy hook
    function mineAndDeploy(
        address _poolManager,
        address _nameWrapper,
        address _textResolver,
        bytes32 _parentNode,
        address _admin,
        address _arcOracle,
        address _paymentManager
    ) internal returns (PermitPoolHook) {
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG);
        
        // Encode arguments
        bytes memory constructorArgs = abi.encode(
            IPoolManager(_poolManager), 
            _nameWrapper, 
            _textResolver, 
            _parentNode, 
            _admin,
            _arcOracle,
            _paymentManager
        );
        
        (address hookAddress, bytes32 salt) = HookMiner.find(
            address(this),
            flags,
            type(PermitPoolHook).creationCode,
            constructorArgs
        );
        
        PermitPoolHook newHook = new PermitPoolHook{salt: salt}(
            IPoolManager(_poolManager),
            _nameWrapper,
            _textResolver,
            _parentNode,
            _admin,
            _arcOracle,
            _paymentManager
        );
        
        require(address(newHook) == hookAddress, "Hook address mismatch");
        return newHook;
    }
    
    function test_NodeCalculation() public {
        vm.prank(address(poolManager));
        bytes32 node = hook.getEnsNodeForAddress(validUser);
        assertEq(node, bytes32(validNode));
    }
    
    /*//////////////////////////////////////////////////////////////
                         DEPLOYMENT TESTS
    //////////////////////////////////////////////////////////////*/
    
    function test_Deployment() public {
        assertEq(address(hook.nameWrapper()), address(nameWrapper));
        assertEq(address(hook.textResolver()), address(textResolver));
        assertEq(hook.parentNode(), parentNode);
        assertEq(hook.admin(), admin);
        assertEq(address(hook.poolManager()), address(poolManager));
    }
    
    function test_DeploymentRevertsWithZeroNameWrapper() public {
        bytes memory args = abi.encode(
            IPoolManager(address(poolManager)), 
            address(0), 
            address(textResolver), 
            parentNode, 
            admin,
            address(1),
            address(2)
        );
        
        (, bytes32 salt) = HookMiner.find(
            address(this),
            uint160(Hooks.BEFORE_SWAP_FLAG),
            type(PermitPoolHook).creationCode,
            args
        );
        
        vm.expectRevert(PermitPoolHook.InvalidAddress.selector);
        new PermitPoolHook{salt: salt}(
            IPoolManager(address(poolManager)),
            address(0), // Zero NameWrapper
            address(textResolver),
            parentNode,
            admin,
            address(1),
            address(2)
        );
    }
    
    function test_DeploymentRevertsWithZeroTextResolver() public {
        bytes memory args = abi.encode(
            IPoolManager(address(poolManager)), 
            address(nameWrapper), 
            address(0), 
            parentNode, 
            admin,
            address(1),
            address(2)
        );
        
        (, bytes32 salt) = HookMiner.find(
            address(this),
            uint160(Hooks.BEFORE_SWAP_FLAG),
            type(PermitPoolHook).creationCode,
            args
        );
        
        vm.expectRevert(PermitPoolHook.InvalidAddress.selector);
        new PermitPoolHook{salt: salt}(
            IPoolManager(address(poolManager)),
            address(nameWrapper),
            address(0), // Zero Resolver
            parentNode,
            admin,
            address(1),
            address(2)
        );
    }
    
    function test_DeploymentRevertsWithZeroAdmin() public {
        bytes memory args = abi.encode(
            IPoolManager(address(poolManager)), 
            address(nameWrapper), 
            address(textResolver), 
            parentNode, 
            address(0),
            address(1),
            address(2)
        );
        
        (, bytes32 salt) = HookMiner.find(
            address(this),
            uint160(Hooks.BEFORE_SWAP_FLAG),
            type(PermitPoolHook).creationCode,
            args
        );
        
        vm.expectRevert(PermitPoolHook.InvalidAddress.selector);
        new PermitPoolHook{salt: salt}(
            IPoolManager(address(poolManager)),
            address(nameWrapper),
            address(textResolver),
            parentNode,
            address(0), // Zero Admin
            address(1),
            address(2)
        );
    }
    
    /*//////////////////////////////////////////////////////////////
                       BEFORESWAP HAPPY PATH
    //////////////////////////////////////////////////////////////*/
    
    function test_BeforeSwap_ValidUser() public {
        // Prank as Pool Manager
        vm.prank(address(poolManager));
        (bytes4 selector,,) = hook.beforeSwap(
            validUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            SwapParams({
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
        vm.prank(address(poolManager));
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
            SwapParams({
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
        
        vm.prank(address(poolManager));
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
            SwapParams({
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
        // Correct node calculation
        bytes32 bobNode = keccak256(abi.encodePacked(parentNode, keccak256("bob")));
        uint256 node = uint256(bobNode);
        
        nameWrapper.setName(noTransferFuseUser, "bob.permitpool.eth");
        nameWrapper.setOwner(node, noTransferFuseUser);
        // Only PARENT_CANNOT_CONTROL, missing CANNOT_TRANSFER
        nameWrapper.setFuses(bytes32(node), PARENT_CANNOT_CONTROL);
        textResolver.setText(bytes32(node), "arc.credential", "valid");
        
        vm.prank(address(poolManager));
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
            SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    function test_BeforeSwap_RevertsInvalidFuses_MissingParentControl() public {
        address noParentControlUser = address(0x5);
        // Correct node calculation
        bytes32 charlieNode = keccak256(abi.encodePacked(parentNode, keccak256("charlie")));
        uint256 node = uint256(charlieNode);
        
        nameWrapper.setName(noParentControlUser, "charlie.permitpool.eth");
        nameWrapper.setOwner(node, noParentControlUser);
        // Only CANNOT_TRANSFER, missing PARENT_CANNOT_CONTROL
        nameWrapper.setFuses(bytes32(node), CANNOT_TRANSFER);
        textResolver.setText(bytes32(node), "arc.credential", "valid");
        
        vm.prank(address(poolManager));
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
            SwapParams({
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
        // Correct node calculation
        bytes32 daveNode = keccak256(abi.encodePacked(parentNode, keccak256("dave")));
        uint256 node = uint256(daveNode);
        
        nameWrapper.setName(noCredentialUser, "dave.permitpool.eth");
        nameWrapper.setOwner(node, noCredentialUser);
        nameWrapper.setFuses(bytes32(node), CANNOT_TRANSFER | PARENT_CANNOT_CONTROL);
        // NO Arc credential set
        
        vm.prank(address(poolManager));
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
            SwapParams({
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
        vm.prank(address(poolManager));
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
            SwapParams({
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
        vm.prank(address(poolManager));
        hook.beforeSwap(
            validUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            SwapParams({
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
        
        vm.prank(address(poolManager));
        hook.beforeSwap(
            validUser,
            PoolKey({
                currency0: Currency.wrap(address(0)),
                currency1: Currency.wrap(address(1)),
                fee: 0,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            }),
            SwapParams({
                zeroForOne: true,
                amountSpecified: -100,
                sqrtPriceLimitX96: 0
            }),
            ""
        );
    }
    
    function test_LicenseRevoked_Event() public {
        // Note: revokeLicense emits LicenseRevokedEvent with node = 0 if it fails lookup
        // But here we set up validUser lookup in setup()
        // Wait, does setup() set name for validUser? Yes "alice.permitpool.eth"
        // So getEnsNodeForAddress(validUser) should work.
        // It requires name wrapper lookup.
        
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
