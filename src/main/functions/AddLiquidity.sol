// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../storage/Schema.sol";
import "../storage/Storage.sol";
import "./FlashAccounting.sol";
import { Schema as ERC721Schema } from "ecdysisxyz/ERC721/src/main/storage/Schema.sol";
import { Storage as ERC721Storage } from "ecdysisxyz/ERC721/src/main/storage/Storage.sol";

contract AddLiquidity is FlashAccounting {
    function addLiquidity(
        Schema.PoolKey memory key,
        Schema.ModifyPositionParams memory params
    ) external returns (Schema.BalanceDelta memory delta, uint256 tokenId) {
        bytes memory result = this.lock(address(this), abi.encode(key, params));
        (delta, tokenId) = abi.decode(result, (Schema.BalanceDelta, uint256));
    }

    function lockAcquired(address caller, bytes calldata data) external returns (bytes memory) {
        require(msg.sender == address(this), "Only self-call allowed");
        (Schema.PoolKey memory key, Schema.ModifyPositionParams memory params) = abi.decode(data, (Schema.PoolKey, Schema.ModifyPositionParams));
        
        Schema.GlobalState storage $s = Storage.state();
        ERC721Schema.GlobalState storage $erc721 = ERC721Storage.state();
        Schema.PoolId poolId = Schema.PoolId.wrap(keccak256(abi.encode(key)));
        Schema.Pool storage pool = $s.pools[poolId];

        // Call the beforeModifyPosition hook if it exists
        if (address(pool.hooks) != address(0)) {
            require(pool.hooks.beforeModifyPosition(key, params) == IHooks.beforeModifyPosition.selector, "INVALID_BEFORE_MODIFY_POSITION_HOOK");
        }

        // Implement liquidity addition logic here...
        // This is a placeholder for the actual liquidity calculation
        Schema.BalanceDelta memory delta = Schema.BalanceDelta({
            amount0: int256(uint256(params.liquidityDelta)),
            amount1: int256(uint256(params.liquidityDelta))
        });

        // Use flash accounting instead of immediate transfers
        _accountDelta(pool.currency0, delta.amount0);
        _accountDelta(pool.currency1, delta.amount1);

        // Mint LP NFT
        uint256 tokenId = $erc721.totalSupply + 1;
        $erc721.totalSupply = tokenId;
        $erc721.owners[tokenId] = msg.sender;
        $erc721.tokenURIs[tokenId] = "https://example.com/metadata/";

        // Call the afterModifyPosition hook if it exists
        if (address(pool.hooks) != address(0)) {
            require(pool.hooks.afterModifyPosition(key, params, delta) == IHooks.afterModifyPosition.selector, "INVALID_AFTER_MODIFY_POSITION_HOOK");
        }

        // Emit liquidity added event here...

        return abi.encode(delta, tokenId);
    }
}