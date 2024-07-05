// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Schema.sol";
import "./Storage.sol";

contract InitializePool {
    function initialize(Schema.PoolKey memory key, uint160 sqrtPriceX96) external returns (Schema.PoolId poolId) {
        Schema.GlobalState storage $s = Storage.getState();
        
        require(Schema.Currency.unwrap(key.currency0) < Schema.Currency.unwrap(key.currency1), "INVALID_CURRENCY_ORDER");
        require($s.poolIds[key.currency0][key.currency1][key.fee] == Schema.PoolId.wrap(bytes32(0)), "POOL_ALREADY_EXISTS");

        // Call the beforeInitialize hook if it exists
        if (address(key.hooks) != address(0)) {
            require(key.hooks.beforeInitialize(key, sqrtPriceX96) == IHooks.beforeInitialize.selector, "INVALID_BEFORE_INITIALIZE_HOOK");
        }

        poolId = Schema.PoolId.wrap(keccak256(abi.encode(key)));
        $s.pools[poolId] = Schema.Pool({
            currency0: key.currency0,
            currency1: key.currency1,
            fee: key.fee,
            sqrtPriceX96: sqrtPriceX96,
            tick: 0,  // This will be updated in the initialization logic
            liquidity: 0,
            feeGrowthGlobal0X128: 0,
            feeGrowthGlobal1X128: 0,
            protocolFees0: 0,
            protocolFees1: 0,
            hooks: key.hooks
        });

        $s.poolIds[key.currency0][key.currency1][key.fee] = poolId;

        // Perform additional initialization logic here...
        int24 tick = 0; // Calculate the initial tick based on sqrtPriceX96

        // Call the afterInitialize hook if it exists
        if (address(key.hooks) != address(0)) {
            require(key.hooks.afterInitialize(key, sqrtPriceX96, tick) == IHooks.afterInitialize.selector, "INVALID_AFTER_INITIALIZE_HOOK");
        }

        // Emit initialization event...
    }
}