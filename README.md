# UniswapV4 on Meta Contract Framework

This project implements UniswapV4 using the meta contract framework, providing a modular and upgradeable design for the Uniswap protocol.

## Overview

UniswapV4 builds upon the successful features of previous versions while introducing new concepts like hooks and flash accounting. This implementation leverages the meta contract framework to achieve modularity and upgradeability.

## Key Components

- **AddLiquidity**: Handles adding liquidity to pools
- **FlashAccounting**: Implements the flash accounting mechanism
- **InitializePool**: Manages pool initialization
- **Router**: Provides routing functionality for swaps and liquidity provision
- **Swap**: Implements the core swap functionality
- **ERC721Base**: Handles the LP token implementation as ERC721 tokens


---

# Meta Contract Template
Welcome to the Meta Contract Template! This template is your fast track to smart contract development, offering a pre-configured setup with the [Meta Contract](https://github.com/metacontract/mc) framework and essential tools like the [ERC-7201 Storage Location Calculator](https://github.com/metacontract/erc7201). It's designed for developers looking to leverage advanced features and best practices right from the start.

## Quick Start
Ensure you have [Foundry](https://github.com/foundry-rs/foundry) installed, then initialize your project with:
```sh
$ forge init <Your Project Name> -t metacontract/template
```
This command sets up your environment with all the benefits of the meta contract framework, streamlining your development process.

## Features
- Pre-integrated with meta contract for optimal smart contract development with highly flexible upgradeability & maintainability.
- Includes ERC-7201 Storage Location Calculator for calculating storage locations based on ERC-7201 names for enhanced efficiency.
- Ready-to-use project structure for immediate development start.

For detailed documentation and further guidance, visit [Meta Contract Book](https://mc-book.ecdysis.xyz/).

Start building your decentralized applications with meta contract today and enjoy a seamless development experience!
