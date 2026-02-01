// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";

/// @title PermitPoolHook
/// @notice A Uniswap v4 Hook that enforces trading permissions based on ENS licenses
/// @dev Implements beforeSwap to verify ENS subdomain ownership, fuses, Arc DID credentials, and revocation status
contract PermitPoolHook is BaseHook {
    using PoolIdLibrary for PoolKey;

    /*//////////////////////////////////////////////////////////////
                                INTERFACES
    //////////////////////////////////////////////////////////////*/

    /// @notice Interface for ENS Name Wrapper contract
    /// @dev Used to verify ENS subdomain ownership and fuse status
    interface INameWrapper {
        /// @notice Get the owner of an ENS name
        /// @param id The namehash of the ENS name
        /// @return The address of the owner
        function ownerOf(uint256 id) external view returns (address);

        /// @notice Get the fuse data for an ENS name
        /// @param id The namehash of the ENS name
        /// @return owner The owner address
        /// @return fuses The fuses burned for this name
        /// @return expiry The expiry timestamp
        function getData(uint256 id)
            external
            view
            returns (address owner, uint32 fuses, uint64 expiry);

        /// @notice Get the ENS name for an address (reverse lookup)
        /// @param addr The address to lookup
        /// @return The ENS name as bytes
        function names(address addr) external view returns (bytes memory);
    }

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice CANNOT_TRANSFER fuse flag - prevents transfers of the ENS name
    uint32 public constant CANNOT_TRANSFER = 0x10;

    /// @notice PARENT_CANNOT_CONTROL fuse flag - prevents parent from controlling the subdomain
    uint32 public constant PARENT_CANNOT_CONTROL = 0x40000;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice ENS Name Wrapper contract on Sepolia
    INameWrapper public immutable nameWrapper;

    /// @notice Parent ENS node under which subdomains must be registered
    bytes32 public immutable parentNode;

    /// @notice Admin address that can revoke licenses
    address public admin;

    /// @notice Mapping to track revoked licenses by address
    mapping(address => bool) public revokedLicenses;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Thrown when sender doesn't own an ENS subdomain under the parent node
    /// @param sender The address that attempted the swap
    error NoENSSubdomain(address sender);

    /// @notice Thrown when the ENS name doesn't have required fuses burned
    /// @param sender The address that attempted the swap
    /// @param fuses The current fuses for the ENS name
    error InvalidFuses(address sender, uint32 fuses);

    /// @notice Thrown when the ENS name doesn't have a valid Arc DID credential
    /// @param sender The address that attempted the swap
    error NoArcCredential(address sender);

    /// @notice Thrown when the license has been revoked by admin
    /// @param sender The address that attempted the swap
    error LicenseRevoked(address sender);

    /// @notice Thrown when unauthorized address attempts admin function
    error Unauthorized();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a license check is performed during swap
    /// @param sender The address performing the swap
    /// @param node The ENS node being checked
    /// @param passed Whether the check passed
    event LicenseChecked(address indexed sender, bytes32 indexed node, bool passed);

    /// @notice Emitted when a license is revoked by admin
    /// @param sender The address whose license was revoked
    /// @param node The ENS node that was revoked
    event LicenseRevokedEvent(address indexed sender, bytes32 indexed node);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Initialize the PermitPoolHook
    /// @param _poolManager The Uniswap v4 PoolManager contract
    /// @param _nameWrapper The ENS Name Wrapper contract address (Sepolia: 0x0635513f179D50A207757E05759CbD106d7dFcE8)
    /// @param _parentNode The parent ENS node for subdomains
    /// @param _admin The admin address that can revoke licenses
    constructor(
        IPoolManager _poolManager,
        address _nameWrapper,
        bytes32 _parentNode,
        address _admin
    ) BaseHook(_poolManager) {
        nameWrapper = INameWrapper(_nameWrapper);
        parentNode = _parentNode;
        admin = _admin;
    }

    /*//////////////////////////////////////////////////////////////
                            HOOK PERMISSIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the hook permissions
    /// @dev Only beforeSwap is enabled for this hook
    /// @return Hooks.Permissions struct with beforeSwap set to true
    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    /*//////////////////////////////////////////////////////////////
                            HOOK FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Hook executed before a swap
    /// @dev Verifies:
    ///      1. Sender owns an ENS subdomain under parent node
    ///      2. ENS name has CANNOT_TRANSFER and PARENT_CANNOT_CONTROL fuses burned
    ///      3. ENS name has a valid Arc DID credential in text records
    ///      4. License hasn't been revoked by admin
    /// @param sender The address initiating the swap
    /// @param key The pool key
    /// @param params The swap parameters
    /// @param hookData Additional hook data
    /// @return bytes4 The function selector if successful
    /// @return BeforeSwapDelta The delta (always zero for this hook)
    /// @return uint24 LP fee (always zero for this hook)
    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external override returns (bytes4, BeforeSwapDelta, uint24) {
        // TODO: Stage 2 - Implement ENS subdomain ownership check
        // TODO: Stage 2 - Implement fuse verification
        // TODO: Stage 3 - Implement Arc DID credential verification
        // TODO: Stage 3 - Implement license revocation check

        // Placeholder - will be implemented in later stages
        // For now, allow all swaps (will implement verification in stages 2 & 3)

        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Compute the ENS node for a given address
    /// @dev Will be implemented in Stage 2
    /// @param addr The address to get the ENS node for
    /// @return The ENS node (namehash)
    function getENSNodeForAddress(address addr) public view returns (bytes32) {
        // TODO: Stage 2 - Implement ENS node computation
        // This will involve:
        // 1. Get the ENS name for the address (reverse lookup)
        // 2. Compute the namehash
        // 3. Verify it's a subdomain of parentNode
        return bytes32(0);
    }
}
