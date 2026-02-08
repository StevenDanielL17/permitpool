// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

interface INameWrapper {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract TransferParentScript is Script {
    function run() external {
        bytes32 parentNode = vm.envBytes32("PARENT_NODE");
        address oldContract = 0x456D1F06A613d6217374485FD2E9F3BA2fe78822;
        address newContract = vm.envAddress("NEW_LICENSE_MANAGER"); // Set this in .env
        
        address NAME_WRAPPER = 0x0635513f179D50A207757E05759CbD106d7dFcE8;

        console.log("Transferring parent domain...");
        console.log("  From (old contract):", oldContract);
        console.log("  To (new contract):", newContract);
        console.log("  Parent node:", vm.toString(parentNode));

        // This uses vm.prank to call AS the old contract
        // Note: This only works in Foundry scripts, not in real transactions
        vm.prank(oldContract);
        INameWrapper(NAME_WRAPPER).safeTransferFrom(
            oldContract,
            newContract,
            uint256(parentNode),
            1,
            ""
        );

        console.log("Transfer complete!");
    }
}
