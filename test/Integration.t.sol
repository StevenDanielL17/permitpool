// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolModifyLiquidityTest} from "@uniswap/v4-core/src/test/PoolModifyLiquidityTest.sol";
import {PoolSwapTest} from "@uniswap/v4-core/src/test/PoolSwapTest.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "v4-periphery/utils/HookMiner.sol";
import {SortTokens} from "@uniswap/v4-core/test/utils/SortTokens.sol";
import {SafeCast} from "@uniswap/v4-core/src/libraries/SafeCast.sol";
import {Constants} from "@uniswap/v4-core/test/utils/Constants.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {ModifyLiquidityParams, SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";

import {PermitPoolHook} from "../src/PermitPoolHook.sol";
import {LicenseManager} from "../src/LicenseManager.sol";
import {PaymentManager} from "../src/PaymentManager.sol";
import {MockArcOracle} from "../src/MockArcOracle.sol";

contract MockNameWrapper {
    mapping(uint256 => address) public owners;
    mapping(uint256 => FuseData) public fuseData;
    mapping(address => bytes) public names; 
    
    struct FuseData {
        address owner;
        uint32 fuses;
        uint64 expiry;
    }
    
    function setSubnodeOwner(bytes32 parentNode, string calldata label, address owner, uint32 fuses, uint64 expiry) external returns (bytes32 node) {
        node = keccak256(abi.encodePacked(parentNode, keccak256(bytes(label))));
        uint256 tokenId = uint256(node);
        owners[tokenId] = owner;
        fuseData[tokenId] = FuseData(owner, fuses, expiry);
        return node;
    }
    
    function ownerOf(uint256 id) external view returns (address) {
        return owners[id];
    }
    
    function getData(uint256 id) external view returns (address owner, uint32 fuses, uint64 expiry) {
        FuseData memory data = fuseData[id];
        return (data.owner, data.fuses, data.expiry);
    }
    
    function setName(address addr, string memory name) external {
        names[addr] = bytes(name);
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

contract MockYellowSession {
    mapping(bytes32 => bool) public active;
    function setSession(bytes32 id, bool isActive) external {
        active[id] = isActive;
    }
    function isSessionActive(bytes32 sessionId) external view returns (bool) {
        return active[sessionId];
    }
    function getSessionExpiry(bytes32) external pure returns (uint256) { return 0; }
}

contract IntegrationTest is Test, Deployers {
    using CurrencyLibrary for Currency;
    using SafeCast for uint256;

    PermitPoolHook hook;
    LicenseManager licenseManager;
    PaymentManager paymentManager;
    MockArcOracle arcOracle;
    
    MockNameWrapper nameWrapper;
    MockResolver textResolver;
    MockYellowSession yellowSession;
    
    address admin = address(0xAD);
    address alice = address(0x1111);
    
    bytes32 parentNode;
    bytes32 permitpoolNode;
    
    function setUp() public {
        deployFreshManagerAndRouters();
        
        nameWrapper = new MockNameWrapper();
        textResolver = new MockResolver();
        yellowSession = new MockYellowSession();
        arcOracle = new MockArcOracle(admin);
        
        bytes32 ethNode = keccak256(abi.encodePacked(bytes32(0), keccak256("eth")));
        permitpoolNode = keccak256(abi.encodePacked(ethNode, keccak256("permitpool")));
        parentNode = permitpoolNode;
        
        vm.prank(admin);
        licenseManager = new LicenseManager(address(nameWrapper), address(textResolver), parentNode, admin);
        
        vm.prank(admin);
        paymentManager = new PaymentManager(address(yellowSession), admin);
        
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG);
        address hookAddress;
        bytes32 salt;
        
        bytes memory constructorArgs = abi.encode(
            manager,
            address(nameWrapper),
            address(textResolver),
            parentNode,
            admin
        );
        
        (hookAddress, salt) = HookMiner.find(address(this), flags, type(PermitPoolHook).creationCode, constructorArgs);
        
        hook = new PermitPoolHook{salt: salt}(
            manager,
            address(nameWrapper),
            address(textResolver),
            parentNode,
            admin
        );
        require(address(hook) == hookAddress, "Hook address mismatch");
        
        (currency0, currency1) = deployMintAndApprove2Currencies();
        
        (key, ) = initPool(
            currency0,
            currency1,
            hook,
            3000,
            SQRT_PRICE_1_1
        );
        
        // Add full range liquidity to ensure swaps don't fail due to slippage
        modifyLiquidityRouter.modifyLiquidity(
            key,
            ModifyLiquidityParams({
                tickLower: -887220, // Must be divisible by 60
                tickUpper: 887220,
                liquidityDelta: 100 ether,
                salt: bytes32(0)
            }),
            ZERO_BYTES
        );
    }
    
    function test_EndToEnd_LicenseFlow() public {
        address user = address(swapRouter);
        
        MockERC20(Currency.unwrap(currency0)).mint(alice, 100 ether);
        MockERC20(Currency.unwrap(currency1)).mint(alice, 100 ether);
        
        vm.startPrank(alice);
        IERC20(Currency.unwrap(currency0)).approve(address(swapRouter), type(uint256).max);
        IERC20(Currency.unwrap(currency1)).approve(address(swapRouter), type(uint256).max);
        vm.stopPrank();
        
        vm.prank(alice);
        vm.expectRevert(); 
        swapRouter.swap(
            key,
            SwapParams({
                zeroForOne: true,
                amountSpecified: -1 ether,
                sqrtPriceLimitX96: MIN_PRICE_LIMIT
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            ZERO_BYTES
        );
        
        string memory label = "router";
        string memory credHash = "valid-cred-hash";
        
        vm.prank(admin);
        licenseManager.issueLicense(user, label, credHash);
        
        nameWrapper.setName(user, "router.permitpool.eth");
        
        bytes32 credId = keccak256(bytes(credHash)); 
        vm.prank(admin);
        arcOracle.issueCredential(credId, user);
        
        vm.prank(alice);
        swapRouter.swap(
            key,
            SwapParams({
                zeroForOne: true,
                amountSpecified: -1 ether,
                sqrtPriceLimitX96: MIN_PRICE_LIMIT
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            ZERO_BYTES
        );
        
        vm.prank(admin);
        hook.revokeLicense(user);
        
        vm.prank(alice);
        vm.expectRevert(); 
        swapRouter.swap(
            key,
            SwapParams({
                zeroForOne: true,
                amountSpecified: -1 ether,
                sqrtPriceLimitX96: MIN_PRICE_LIMIT
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            ZERO_BYTES
        );
        
        vm.prank(admin);
        hook.restoreLicense(user);
        
        vm.prank(alice);
        swapRouter.swap(
            key,
            SwapParams({
                zeroForOne: true,
                amountSpecified: -1 ether,
                sqrtPriceLimitX96: MIN_PRICE_LIMIT
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            ZERO_BYTES
        );
    }
}
