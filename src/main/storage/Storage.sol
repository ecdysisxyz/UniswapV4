// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Schema} from "./Schema.sol";

// cast index-erc7201 ecdysisxyz.uniswapv4.globalstate
library Storage {
    function state() internal pure returns(Schema.GlobalState storage s) {
        assembly { s.slot := 0xbe78c1d33164b580954f6668d2799c524fdaa753aa75add1b117b997408fee00 }
    }
}