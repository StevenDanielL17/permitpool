// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";

interface IRegistry {
    function owner(bytes32 node) external view returns (address);
}

interface IBaseRegistrar {
    function reclaim(uint256 id, address owner) external;
    function ownerOf(uint256 id) external view returns (address);
}

contract CheckRegistryScript is Script {
    address constant REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    address constant BASE_REGISTRAR = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;
    address constant NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");
        bytes32 node = 0x5c7ff35237c2a59c3cfa914cbc481abf5b6e11a7fae301b8290d0a0deed3deb9;
        uint256 tokenId = uint256(keccak256(bytes("myhedgefund")));

        console.log("Checking Registry Ownership...");
        address registryOwner = IRegistry(REGISTRY).owner(node);
        console.log("Registry Owner:", registryOwner);
        console.log("Deployer:", deployer);

        address nftOwner = IBaseRegistrar(BASE_REGISTRAR).ownerOf(tokenId);
        console.log("NFT Owner:", nftOwner);

        if (nftOwner == NAME_WRAPPER && registryOwner == deployer) {
            console.log("Desync detected! Registry owner is Deployer, but NFT is in NameWrapper.");
            console.log("Attempting to Reclaim NFT from NameWrapper...");
            
            vm.startBroadcast(deployerPrivateKey);
            IBaseRegistrar(BASE_REGISTRAR).reclaim(tokenId, deployer);
            vm.stopBroadcast();
            
            console.log("Reclaim successful! You now own the NFT.");
            console.log("Please run WrapParentName.s.sol again to wrap it properly.");
        } else if (registryOwner == NAME_WRAPPER) {
             console.log("Registry is owned by NameWrapper. Cannot reclaim.");
             console.log("If NameWrapper owner is 0x0, the name is stuck.");
        } else {
            console.log("No obvious desync to fix.");
        }
    }
}
