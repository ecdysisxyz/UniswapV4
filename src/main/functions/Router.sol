// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Schema.sol";
import "./Storage.sol";
import { Schema as ERC721Schema } from "ecdysisxyz/ERC721/src/main/storage/Schema.sol";
import { Storage as ERC721Storage } from "ecdysisxyz/ERC721/src/main/storage/Storage.sol";
import "./Swap.sol";
import "./AddLiquidity.sol";

contract Router is Swap, AddLiquidity {
    function swapExactInputSingle(
        Schema.PoolKey memory key,
        uint256 amountIn,
        uint256 amountOutMinimum,
        address recipient
    ) external returns (uint256 amountOut) {
        Schema.SwapParams memory params = Schema.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(amountIn),
            sqrtPriceLimitX96: 0
        });

        Schema.BalanceDelta memory delta = swap(key, params);
        amountOut = uint256(-delta.amount1);
        require(amountOut >= amountOutMinimum, "Too little received");

        // Transfer tokens to recipient
        if (recipient != address(this)) {
            Schema.Currency outputCurrency = key.currency1;
            IERC20(Schema.Currency.unwrap(outputCurrency)).transfer(recipient, amountOut);
        }
    }

    function swapExactInputMultiHop(
        Schema.PoolKey[] memory keys,
        uint256 amountIn,
        uint256 amountOutMinimum,
        address recipient
    ) external returns (uint256 amountOut) {
        require(keys.length >= 2, "Must swap through at least 2 pools");

        uint256 currentAmountIn = amountIn;
        for (uint i = 0; i < keys.length; i++) {
            bool zeroForOne = i % 2 == 0;
            Schema.SwapParams memory params = Schema.SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: int256(currentAmountIn),
                sqrtPriceLimitX96: 0
            });

            Schema.BalanceDelta memory delta = swap(keys[i], params);
            currentAmountIn = uint256(zeroForOne ? -delta.amount1 : -delta.amount0);
        }

        amountOut = currentAmountIn;
        require(amountOut >= amountOutMinimum, "Too little received");

        // Transfer tokens to recipient
        if (recipient != address(this)) {
            Schema.Currency outputCurrency = keys[keys.length - 1].currency1;
            IERC20(Schema.Currency.unwrap(outputCurrency)).transfer(recipient, amountOut);
        }
    }

    function addLiquiditySingle(
        Schema.PoolKey memory key,
        uint256 amount0,
        uint256 amount1,
        int24 tickLower,
        int24 tickUpper
    ) external returns (uint256 tokenId) {
        Schema.ModifyPositionParams memory params = Schema.ModifyPositionParams({
            tickLower: tickLower,
            tickUpper: tickUpper,
            liquidityDelta: int128(uint128(amount0 + amount1))  // Simplified, should calculate actual liquidity
        });

        (Schema.BalanceDelta memory delta, uint256 _tokenId) = addLiquidity(key, params);
        tokenId = _tokenId;

        // Transfer tokens to the contract
        IERC20(Schema.Currency.unwrap(key.currency0)).transferFrom(msg.sender, address(this), uint256(delta.amount0));
        IERC20(Schema.Currency.unwrap(key.currency1)).transferFrom(msg.sender, address(this), uint256(delta.amount1));
    }

    function removeLiquidity(
        Schema.PoolKey memory key,
        uint256 tokenId,
        int24 tickLower,
        int24 tickUpper
    ) external returns (uint256 amount0, uint256 amount1) {
        ERC721Schema.GlobalState storage $erc721 = ERC721Storage.state();
        require($erc721.owners[tokenId] == msg.sender, "Not token owner");

        // Calculate liquidity to remove (this would typically come from the position info)
        uint128 liquidityToRemove = 100; // Placeholder value

        Schema.ModifyPositionParams memory params = Schema.ModifyPositionParams({
            tickLower: tickLower,
            tickUpper: tickUpper,
            liquidityDelta: -int128(liquidityToRemove)
        });

        (Schema.BalanceDelta memory delta, ) = addLiquidity(key, params);

        // Burn the LP NFT
        $erc721.owners[tokenId] = address(0);

        // Transfer tokens back to the user
        amount0 = uint256(-delta.amount0);
        amount1 = uint256(-delta.amount1);
        IERC20(Schema.Currency.unwrap(key.currency0)).transfer(msg.sender, amount0);
        IERC20(Schema.Currency.unwrap(key.currency1)).transfer(msg.sender, amount1);
    }
}