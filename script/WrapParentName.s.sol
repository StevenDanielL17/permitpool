// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

interface IBaseRegistrar {
    function approve(address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface INameWrapper {
    function wrapETH2LD(
        string calldata label,
        address wrappedOwner,
        uint16 ownerControlledFuses,
        address resolver
    ) external returns (uint64);
}

contract WrapParentNameScript is Script {
    address constant NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8; // Sepolia NameWrapper
    address constant BASE_REGISTRAR = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85; // Sepolia .eth Registrar (Correct Address)

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address deployer = vm.envAddress("OWNER_ADDRESS");
        
        string memory label = vm.envString("PARENT_LABEL");
        bytes32 labelHash = keccak256(bytes(label));
        uint256 tokenId = uint256(labelHash);
        
        console.log("Wrapping myhedgefund.eth...");
        console.log("  Deployer:", deployer);
        console.log("  Token ID:", tokenId);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Check current owner in BaseRegistrar
        // If this reverts or returns != deployer, we know the issue.
        try IBaseRegistrar(BASE_REGISTRAR).ownerOf(tokenId) returns (address currentOwner) {
            console.log("  Current owner in BaseRegistrar:", currentOwner);
            require(currentOwner == deployer, "ERROR: Deployer does not own 'myhedgefund.eth'!");
        } catch {
            console.log("  ERROR: 'myhedgefund.eth' is not registered in the BaseRegistrar.");
            console.log("  ACTION REQUIRED: Go to app.ens.domains (Sepolia) and register it.");
            revert("Domain not registered");
        }
        
        // 2. Approve NameWrapper to take the NFT
        console.log("Approving NameWrapper to take NFT...");
        IBaseRegistrar(BASE_REGISTRAR).approve(NAME_WRAPPER, tokenId);
        
        // 3. Wrap it
        console.log("Wrapping name via wrapETH2LD...");
        // 0 fuses burned initially, resolver = address(0) uses default
        INameWrapper(NAME_WRAPPER).wrapETH2LD(
            label,           // "myhedgefund"
            deployer,        // New wrapped owner (should act as controller)
            0,               // No fuses burned on parent
            address(0)       // Default resolver
        );
        
        console.log("SUCCESS! myhedgefund.eth is now wrapped!");
        
        vm.stopBroadcast();
    }
}
