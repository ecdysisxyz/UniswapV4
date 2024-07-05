// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "@mc/devkit/Flattened.sol";
import {MCScript} from "@devkit/MCScript.sol";
import {AddLiquidity} from "src/main/functions/AddLiquidity.sol";
import {FlashAccounting} from "src/main/functions/FlashAccounting.sol";
import {InitializePool} from "src/main/functions/InitializePool.sol";
import {Router} from "src/main/functions/Router.sol";
import {Swap} from "src/main/functions/Swap.sol";
import {ERC721Base} from "ecdysisxyz/ERC721/src/main/functions/ERC721Base.sol";

contract Deploy is MCScript {
    function run() external {
        // Initialize the meta contract
        mc.init("UniswapV4");

        // Register functions
        mc.use("AddLiquidity", AddLiquidity);
        mc.use("FlashAccounting", FlashAccounting);
        mc.use("InitializePool", InitializePool);
        mc.use("Router", Router);
        mc.use("Swap", Swap);
        mc.use("ERC721Base", ERC721Base);

        // Deploy the meta contract
        address proxy = mc.deploy();

        console.log("UniswapV4 deployed to:", proxy);
    }
}
