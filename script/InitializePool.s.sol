// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";

contract InitializePoolScript is Script {
    using CurrencyLibrary for Currency;

    // Addresses (update after deployment)
    // For Sepolia, use real PoolManager. For local test, use deployed mock.
    address constant POOL_MANAGER = address(0x88); 
    address constant TOKEN0 = address(0x11); 
    address constant TOKEN1 = address(0x22); 

    function run() external {
        // Required env vars
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address hookAddress = vm.envAddress("HOOK_ADDRESS");

        vm.startBroadcast(privateKey);

        IPoolManager manager = IPoolManager(POOL_MANAGER);

        // Sort tokens to ensure currency0 < currency1
        address t0 = TOKEN0 < TOKEN1 ? TOKEN0 : TOKEN1;
        address t1 = TOKEN0 < TOKEN1 ? TOKEN1 : TOKEN0;
        
        // Ensure tokens are not same
        if (t0 == t1) {
            console.log("Error: Token addresses must differ");
            return;
        }

        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(t0),
            currency1: Currency.wrap(t1),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(hookAddress)
        });

        // Initialize pool at price 1:1 (sqrtPriceX96 = 2^96)
        // 2^96 = 79228162514264337593543950336
        uint160 sqrtPriceX96 = 79228162514264337593543950336;
        
        manager.initialize(key, sqrtPriceX96);
        
        console.log("Pool initialized with Hook:", hookAddress);

        vm.stopBroadcast();
    }
}
