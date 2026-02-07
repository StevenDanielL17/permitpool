// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";

interface IBaseRegistrar {
    function ownerOf(uint256 id) external view returns (address);
    function nameExpires(uint256 id) external view returns (uint256);
}

interface IRegistry {
    function owner(bytes32 node) external view returns (address);
}

interface INameWrapper {
    function ownerOf(uint256 id) external view returns (address);
    function getData(uint256 id) external view returns (address owner, uint32 fuses, uint64 expiry);
}

contract DebugENSScript is Script {
    address constant NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;
    address constant BASE_REGISTRAR = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;
    address constant REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    function run() external {
        string memory label = "myhedgefund";
        bytes32 labelHash = keccak256(bytes(label));
        uint256 tokenId = uint256(labelHash);
        bytes32 node = namehash("myhedgefund.eth");

        console.log("Debugging myhedgefund.eth...");
        console.log("LabelHash:", tokenId);
        console.log("Node:", uint256(node));

        // 1. BaseRegistrar
        try IBaseRegistrar(BASE_REGISTRAR).ownerOf(tokenId) returns (address nftOwner) {
            console.log("BaseRegistrar (NFT) Owner:", nftOwner);
        } catch {
            console.log("BaseRegistrar: Token does not exist (not registered?)");
        }

        try IBaseRegistrar(BASE_REGISTRAR).nameExpires(tokenId) returns (uint256 expiry) {
            console.log("BaseRegistrar Expiry:", expiry);
            if (expiry < block.timestamp) {
                console.log("  [EXPIRED]");
            } else {
                console.log("  [VALID]");
            }
        } catch {}

        // 2. Registry
        try IRegistry(REGISTRY).owner(node) returns (address registryOwner) {
            console.log("Legacy Registry Owner:", registryOwner);
        } catch {}

        // 3. NameWrapper
        try INameWrapper(NAME_WRAPPER).ownerOf(uint256(node)) returns (address wrapperOwner) {
            console.log("NameWrapper Owner:", wrapperOwner);
        } catch {}

        try INameWrapper(NAME_WRAPPER).getData(uint256(node)) returns (address owner, uint32 fuses, uint64 expiry) {
            console.log("NameWrapper Data:");
            console.log("  Owner:", owner);
            console.log("  Fuses:", fuses);
            console.log("  Expiry:", expiry);
        } catch {}
    }

    function namehash(string memory name) internal pure returns (bytes32) {
        // Hardcoded for myhedgefund.eth
        // 0x5c7ff35237c2a59c3cfa914cbc481abf5b6e11a7fae301b8290d0a0deed3deb9
        return 0x5c7ff35237c2a59c3cfa914cbc481abf5b6e11a7fae301b8290d0a0deed3deb9;
    }
}
