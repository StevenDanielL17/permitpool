// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "v4-periphery/utils/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";

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

/// @notice Interface for ENS Text Resolver
/// @dev Used to read text records from ENS names
interface ITextResolver {
    /// @notice Get a text record for an ENS node
    /// @param node The namehash of the ENS name
    /// @param key The text record key (e.g., "arc.credential")
    /// @return The text record value
    function text(bytes32 node, string calldata key) external view returns (string memory);
}

import {ArcOracle} from "./ArcOracle.sol";
import {PaymentManager} from "./PaymentManager.sol";

/*//////////////////////////////////////////////////////////////
                            CONTRACT
//////////////////////////////////////////////////////////////*/

/// @title PermitPoolHook
/// @notice A Uniswap v4 Hook that enforces trading permissions based on ENS licenses
/// @dev Implements beforeSwap to verify ENS subdomain ownership, fuses, Arc DID credentials, and revocation status
contract PermitPoolHook is BaseHook {

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice CANNOT_TRANSFER fuse flag - prevents transfers of the ENS name
    uint32 public constant CANNOT_TRANSFER = 0x4; // 0x4 = Bit 2

    /// @notice PARENT_CANNOT_CONTROL fuse flag - prevents parent from controlling the subdomain
    uint32 public constant PARENT_CANNOT_CONTROL = 0x10000; // 0x10000 = Bit 16

    /// @notice Text record key for Arc DID credentials
    string public constant ARC_CREDENTIAL_KEY = "arc.credential";

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice ENS Name Wrapper contract on Sepolia
    INameWrapper public immutable nameWrapper;

    /// @notice ENS Public Resolver for text records
    ITextResolver public immutable textResolver;

    /// @notice Parent ENS node under which subdomains must be registered
    bytes32 public immutable parentNode;

    /// @notice Admin address that can revoke licenses
    address public admin;

    /// @notice Arc Oracle for verifying credentials
    ArcOracle public immutable arcOracle;
    
    /// @notice Payment Manager for checking Yellow Network sessions
    PaymentManager public immutable paymentManager;

    /// @notice Mapping to track revoked licenses by address
    mapping(address => bool) public revokedLicenses;

    /// @notice Mapping to track ENS node assigned to each licensed address
    /// @dev Populated when licenses are issued via registerLicenseNode
    /// @notice Mapping to track ENS node assigned to each licensed address
    /// @dev Populated when licenses are issued via registerLicenseNode
    mapping(address => bytes32) public userLicenseNode;

    /// @notice Address of the LicenseManager contract
    address public licenseManager;

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

    /// @notice Thrown when the ENS name lacks an Arc DID credential text record
    /// @param sender The address that attempted the swap
    error NoArcCredential(address sender);
    
    /// @notice Thrown when the Arc credential is invalid
    error InvalidCredential(address sender);

    /// @notice Thrown when the license has been revoked by admin
    /// @param sender The address that attempted the swap
    error LicenseRevoked(address sender);

    /// @notice Thrown when the caller is not the admin
    error Unauthorized();

    /// @notice Thrown when an address parameter is zero
    error InvalidAddress();

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

    /// @notice Emitted when a license is restored by admin
    /// @param user The address whose license was restored
    event LicenseRestored(address indexed user);

    /// @notice Emitted when admin rights are transferred
    /// @param oldAdmin The previous admin address
    /// @param newAdmin The new admin address
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);

    /// @notice Emitted when the license manager address is updated
    /// @param newLicenseManager The new license manager address
    event LicenseManagerUpdated(address indexed newLicenseManager);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Initialize the PermitPoolHook
    /// @param _poolManager The Uniswap v4 PoolManager contract
    /// @param _nameWrapper The ENS Name Wrapper contract address (Sepolia: 0x0635513f179D50A207757E05759CbD106d7dFcE8)
    /// @param _textResolver The ENS Public Resolver contract address (Sepolia: 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD)
    /// @param _parentNode The parent ENS node for subdomains
    /// @param _admin The admin address that can revoke licenses
    /// @param _arcOracle The Arc Oracle address
    /// @param _paymentManager The Payment Manager address
    constructor(
        IPoolManager _poolManager,
        address _nameWrapper,
        address _textResolver,
        bytes32 _parentNode,
        address _admin,
        address _arcOracle,
        address _paymentManager
    ) BaseHook(_poolManager) {
        // Validate addresses
        if (_nameWrapper == address(0)) revert InvalidAddress();
        if (_textResolver == address(0)) revert InvalidAddress();
        if (_admin == address(0)) revert InvalidAddress();
        if (_arcOracle == address(0)) revert InvalidAddress();
        if (_paymentManager == address(0)) revert InvalidAddress();

        nameWrapper = INameWrapper(_nameWrapper);
        textResolver = ITextResolver(_textResolver);
        parentNode = _parentNode;
        admin = _admin;
        arcOracle = ArcOracle(_arcOracle);
        paymentManager = PaymentManager(_paymentManager);
    }

    /*//////////////////////////////////////////////////////////////
                        LICENSE REGISTRATION
    //////////////////////////////////////////////////////////////*/

    /// @notice Set or update the LicenseManager contract address
    /// @param _licenseManager The address of the LicenseManager contract
    function setLicenseManager(address _licenseManager) external {
        if (msg.sender != admin) revert Unauthorized();
        if (_licenseManager == address(0)) revert InvalidAddress();
        licenseManager = _licenseManager;
        emit LicenseManagerUpdated(_licenseManager);
    }

    /// @notice Register an ENS license node for an address
    /// @dev Called by LicenseManager when issuing a license
    /// @param licensee The address receiving the license
    /// @param node The ENS node being assigned
    function registerLicenseNode(address licensee, bytes32 node) external {
        // Allow admin or LicenseManager to register licenses
        if (msg.sender != admin && msg.sender != licenseManager) revert Unauthorized();
        
        if (licensee == address(0)) revert InvalidAddress();
        if (node == bytes32(0)) revert InvalidAddress();
        
        userLicenseNode[licensee] = node;
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
    /// @return bytes4 The function selector if successful
    /// @return BeforeSwapDelta The delta (always zero for this hook)
    /// @return uint24 LP fee (always zero for this hook)
    function _beforeSwap(
        address sender,
        PoolKey calldata /* key */,
        SwapParams calldata /* params */,
        bytes calldata /* hookData */
    ) internal override returns (bytes4, BeforeSwapDelta, uint24) {
        // ✅ OPTIMIZATION: Check revocation first (cheapest - mapping read)
        // This saves gas for revoked users and returns early
        if (revokedLicenses[sender]) {
            revert LicenseRevoked(sender);
        }

        // Then verify ENS ownership and get node
        bytes32 node = _verifyENSOwnership(sender);
        
        // Verify required fuses are burned
        _verifyFuses(node, sender);
        
        // Verify Arc DID credential
        _verifyArcCredential(node, sender);

        // Check Yellow Network Payment
        if (!paymentManager.isPaymentCurrent(node)) {
            revert LicenseRevoked(sender);
        }
        
        // Emit success event
        emit LicenseChecked(sender, node, true);
        
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _verifyArcCredential(bytes32 node, address sender) internal view {
        // Get Arc DID credential from text records
        string memory credential = textResolver.text(node, ARC_CREDENTIAL_KEY);
        
        // Credential must exist
        if (bytes(credential).length == 0) {
            revert NoArcCredential(sender);
        }
        
        // Real Arc Oracle Check
        if (!arcOracle.isValidCredential(keccak256(bytes(credential)))) {
            revert InvalidCredential(sender);
        }
    }

    /// @notice Compute the ENS node for a given address
    /// @dev First checks the userLicenseNode mapping, then falls back to ENS reverse lookup
    /// @param addr The address to get the ENS node for
    /// @return The ENS node (namehash)
    function getENSNodeForAddress(address addr) public view returns (bytes32) {
        // First, check if the address has a registered license node in our mapping
        // This is the primary method since it doesn't rely on ENS reverse resolution setup
        bytes32 node = userLicenseNode[addr];
        if (node != bytes32(0)) {
            return node;
        }
        
        // Fallback: Try ENS reverse lookup
        bytes memory ensNameBytes = nameWrapper.names(addr);
        
        // Check if address has an ENS name
        if (ensNameBytes.length == 0) {
            revert NoENSSubdomain(addr);
        }
        
        // Convert bytes to string for processing
        string memory ensName = string(ensNameBytes);
        
        // Compute the namehash of the ENS name and verify parent relationship
        (bytes32 resolvedNode, bool isSubdomain) = _computeNamehashAndCheckParent(ensName, parentNode);
        
        // Verify the node is a subdomain of parentNode
        if (!isSubdomain) {
            revert NoENSSubdomain(addr);
        }
        
        // Additional check: Ensure we didn't just get the root or empty name
        if (resolvedNode == bytes32(0)) {
            revert NoENSSubdomain(addr);
        }
        
        return resolvedNode;
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL VERIFICATION FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Verify that the sender owns an ENS subdomain
    /// @dev Internal function called by beforeSwap
    /// @param sender The address to verify ownership for
    /// @return node The ENS node (namehash) of the owned subdomain
    function _verifyENSOwnership(address sender) internal view returns (bytes32 node) {
        // Get the ENS node for the sender
        node = getENSNodeForAddress(sender);
        
        // Verify the sender owns the ENS name
        address owner = nameWrapper.ownerOf(uint256(node));
        if (owner != sender) {
            revert NoENSSubdomain(sender);
        }
        
        return node;
    }

    /// @notice Verify that the required fuses are burned for the ENS name
    /// @dev Internal function called by beforeSwap
    /// @param node The ENS node (namehash) to check
    /// @param sender The address attempting the swap (for error reporting)
    function _verifyFuses(bytes32 node, address sender) internal view {
        // Get fuse data from Name Wrapper
        (, uint32 fuses,) = nameWrapper.getData(uint256(node));
        
        // Check CANNOT_TRANSFER fuse (0x4)
        bool hasCannotTransfer = (fuses & CANNOT_TRANSFER) != 0;
        
        // Check PARENT_CANNOT_CONTROL fuse (0x10000)
        bool hasParentCannotControl = (fuses & PARENT_CANNOT_CONTROL) != 0;
        
        // Both fuses must be burned
        if (!hasCannotTransfer || !hasParentCannotControl) {
            revert InvalidFuses(sender, fuses);
        }
    }

    /// @notice Check if the license has been revoked by admin
    /// @dev Internal function called by beforeSwap
    /// @param sender The address to check
    function _checkRevocation(address sender) internal view {
        if (revokedLicenses[sender]) {
            revert LicenseRevoked(sender);
        }
    }

    /// @notice Batch verify all license properties at once
    /// @dev Allows frontend to check all conditions in a single RPC call
    /// @param user The address to verify
    /// @return isValid Whether all checks pass
    /// @return node The ENS node for this user
    /// @return revoked Whether the license is revoked
    /// @return paymentCurrent Whether payment is current
    function batchVerifyLicense(address user) external view returns (
        bool isValid,
        bytes32 node,
        bool revoked,
        bool paymentCurrent
    ) {
        // Quick check: revocation (cheapest)
        revoked = revokedLicenses[user];
        if (revoked) {
            return (false, bytes32(0), true, false);
        }

        // Get node
        try this.getENSNodeForAddress(user) returns (bytes32 _node) {
            node = _node;
        } catch {
            return (false, bytes32(0), false, false);
        }

        // Check payment status
        try paymentManager.isPaymentCurrent(node) returns (bool _paymentCurrent) {
            paymentCurrent = _paymentCurrent;
        } catch {
            paymentCurrent = false;
        }

        // All checks passed
        isValid = !revoked && paymentCurrent && node != bytes32(0);
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Restricts function access to admin only
    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert Unauthorized();
        }
        _;
    }

    /// @notice Revoke a license for an address
    /// @param user The address to revoke
    function revokeLicense(address user) external onlyAdmin {
        revokedLicenses[user] = true;
        
        // Try to get the ENS node for event emission, but don't revert if it fails
        bytes32 node = bytes32(0);
        try this.getENSNodeForAddress(user) returns (bytes32 _node) {
            node = _node;
        } catch {
            // If getting the node fails, just use zero
        }
        
        emit LicenseRevokedEvent(user, node);
    }

    /// @notice Restore a previously revoked license
    /// @param user The address to restore
    function restoreLicense(address user) external onlyAdmin {
        revokedLicenses[user] = false;
        emit LicenseRestored(user);
    }

    /// @notice Transfer admin rights to a new address
    /// @param newAdmin The new admin address
    function updateAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert InvalidAddress();
        address oldAdmin = admin;
        admin = newAdmin;
        emit AdminUpdated(oldAdmin, newAdmin);
    }

    /*//////////////////////////////////////////////////////////////
                        NAMEHASH COMPUTATION
    //////////////////////////////////////////////////////////////*/

    /// @notice Compute the ENS namehash for a given name and check if it's a subdomain of parentNode
    /// @dev Implements the ENS namehash algorithm
    /// @param name The ENS name (e.g., "alice.permitpool.eth")
    /// @param _parentNode The parent node to check against
    /// @return node The namehash of the name
    /// @return isSubdomain Whether the name is a subdomain of (or is) the parent node
    function _computeNamehashAndCheckParent(string memory name, bytes32 _parentNode) internal pure returns (bytes32 node, bool isSubdomain) {
        // Start with the root hash (zero)
        bytes32 namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        
        // If parentNode is root, everything is a subdomain
        if (_parentNode == bytes32(0)) {
            isSubdomain = true;
        } else {
            isSubdomain = (namehash == _parentNode);
        }
        
        // Convert string to bytes for processing
        bytes memory nameBytes = bytes(name);
        
        // If empty name, return root hash
        if (nameBytes.length == 0) {
            return (namehash, isSubdomain);
        }
        
        // Split the name by dots and hash from right to left
        // This is a simplified implementation
        
        uint256 end = nameBytes.length;
        uint256 start = end;
        
        // Process labels from right to left (e.g., eth -> permitpool -> alice)
        while (start > 0) {
            // Find the next dot (or start of string)
            start--;
            if (start == 0 || nameBytes[start - 1] == bytes1('.')) {
                // Extract label
                bytes memory label = new bytes(end - start);
                for (uint256 i = 0; i < label.length; i++) {
                    label[i] = nameBytes[start + i];
                }
                
                // Compute: namehash = keccak256(namehash + keccak256(label))
                namehash = keccak256(abi.encodePacked(namehash, keccak256(label)));
                
                // Check if we encountered the parent node
                if (namehash == _parentNode) {
                    isSubdomain = true;
                }
                
                // Move end pointer to before the dot
                end = start > 0 ? start - 1 : 0;
                start = end;
            }
        }
        
        return (namehash, isSubdomain);
    }
}
