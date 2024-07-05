// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Schema {
    /// @custom:storage-location erc7201:ecdysisxyz.uniswapv4.globalstate
    struct GlobalState {
        mapping(PoolId => Pool) pools;
        mapping(Currency => mapping(Currency => mapping(uint24 => PoolId))) poolIds;
        uint256 protocolFeeGrowthGlobal;
        address feeController;
        mapping(address => mapping(Currency => int256)) currencyDeltas;
        uint256 nonzeroDeltaCount;
        address[] lockers;
    }

    struct Pool {
        Currency currency0;
        Currency currency1;
        uint24 fee;
        uint160 sqrtPriceX96;
        int24 tick;
        uint128 liquidity;
        uint256 feeGrowthGlobal0X128;
        uint256 feeGrowthGlobal1X128;
        uint256 protocolFees0;
        uint256 protocolFees1;
        IHooks hooks;
        mapping(int24 => Tick) ticks;
        mapping(bytes32 => Position) positions;
    }

    struct Tick {
        uint128 liquidityGross;
        int128 liquidityNet;
        uint256 feeGrowthOutside0X128;
        uint256 feeGrowthOutside1X128;
    }

    struct Position {
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    struct PoolKey {
        Currency currency0;
        Currency currency1;
        uint24 fee;
        IHooks hooks;
        int24 tickSpacing;
    }

    struct ModifyPositionParams {
        int24 tickLower;
        int24 tickUpper;
        int128 liquidityDelta;
    }

    struct SwapParams {
        bool zeroForOne;
        int256 amountSpecified;
        uint160 sqrtPriceLimitX96;
    }

    struct BalanceDelta {
        int256 amount0;
        int256 amount1;
    }

    type Currency is address;
    type PoolId is bytes32;
}

interface IHooks {
    function beforeInitialize(Schema.PoolKey calldata key, uint160 sqrtPriceX96) external returns (bytes4);
    function afterInitialize(Schema.PoolKey calldata key, uint160 sqrtPriceX96, int24 tick) external returns (bytes4);
    function beforeModifyPosition(Schema.PoolKey calldata key, Schema.ModifyPositionParams calldata params) external returns (bytes4);
    function afterModifyPosition(Schema.PoolKey calldata key, Schema.ModifyPositionParams calldata params, Schema.BalanceDelta delta) external returns (bytes4);
    function beforeSwap(Schema.PoolKey calldata key, Schema.SwapParams calldata params) external returns (bytes4);
    function afterSwap(Schema.PoolKey calldata key, Schema.SwapParams calldata params, Schema.BalanceDelta delta) external returns (bytes4);
}