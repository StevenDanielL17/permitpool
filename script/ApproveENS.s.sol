// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";

// Ensure this matches your deployment!
address constant LICENSE_MANAGER = 0xDEE0aE670265178b4442A20924d7c31bc7c65370;
address constant NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;

// Minimal interface for setSubnodeOwner to check permissions directly if needed
interface INameWrapper {
    function setSubnodeOwner(
        bytes32 parentNode,
        string memory label,
        address owner,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node);
    function ownerOf(uint256 id) external view returns (address);
}

contract ApproveENSScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");
        bytes32 parentNode = vm.envBytes32("PARENT_NODE");
        
        console.log("Checking ENS Permissions for LicenseManager...");
        console.log("  Owner:", deployer);
        console.log("  LicenseManager:", LICENSE_MANAGER);
        console.log("  Parent Node:", uint256(parentNode));
        
        vm.startBroadcast(deployerPrivateKey);

        INameWrapper nameWrapper = INameWrapper(NAME_WRAPPER);
        
        // Check ownership of the parent node
        address parentOwner = nameWrapper.ownerOf(uint256(parentNode));
        console.log("  Parent Node Owner:", parentOwner);
        if (parentOwner != deployer) {
            console.log("  WARNING: Deployer does not own the parent node on NameWrapper!");
        }

        // 1. Approve LicenseManager as operator for the Deployer on NameWrapper
        // This is required because LicenseManager calls setSubnodeOwner on a node owned by Deployer
        console.log("Approving LicenseManager as operator for Deployer...");
        (bool success, ) = NAME_WRAPPER.call(
            abi.encodeWithSignature("setApprovalForAll(address,bool)", LICENSE_MANAGER, true)
        );
        require(success, "Failed to approve LicenseManager");
        console.log("  Approval successful!");

        vm.stopBroadcast();
    }
}
