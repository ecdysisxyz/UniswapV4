// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../storage/Schema.sol";
import "../storage/Storage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashAccounting {
    event CurrencyDeltaAccounted(address indexed locker, Schema.Currency indexed currency, int256 delta);

    function lock(address lockTarget, bytes calldata data) external payable returns (bytes memory result) {
        Schema.GlobalState storage $s = Storage.getState();
        $s.lockers.push(msg.sender);

        result = ILockCallback(lockTarget).lockAcquired(msg.sender, data);

        if ($s.lockers.length == 1) {
            if ($s.nonzeroDeltaCount != 0) revert("CurrencyNotSettled");
            delete $s.lockers;
        } else {
            $s.lockers.pop();
        }
    }

    function _accountDelta(Schema.Currency currency, int256 delta) internal {
        Schema.GlobalState storage s = Storage.getState();
        if (delta == 0) return;

        address locker = $s.lockers[$s.lockers.length - 1];
        int256 current = $s.currencyDeltas[locker][currency];
        int256 next = current + delta;

        unchecked {
            if (next == 0) {
                $s.nonzeroDeltaCount--;
            } else if (current == 0) {
                $s.nonzeroDeltaCount++;
            }
        }

        $s.currencyDeltas[locker][currency] = next;
        emit CurrencyDeltaAccounted(locker, currency, delta);
    }

    function take(Schema.Currency currency, address to, uint256 amount) external {
        require(msg.sender == Storage.getState().lockers[Storage.getState().locker$s.length - 1], "Not current locker");
        _accountDelta(currency, -int256(amount));
        IERC20(Schema.Currency.unwrap(currency)).transfer(to, amount);
    }

    function settle(Schema.Currency currency) external payable {
        Schema.GlobalState storage s = Storage.getState();
        require(msg.sender == $s.lockers[$s.lockers.length - 1], "Not current locker");
        
        uint256 balance = Schema.Currency.unwrap(currency) == address(0) 
            ? address(this).balance 
            : IERC20(Schema.Currency.unwrap(currency)).balanceOf(address(this));
        uint256 owed = uint256(-$s.currencyDeltas[msg.sender][currency]);
        
        if (Schema.Currency.unwrap(currency) == address(0)) {
            require(msg.value >= owed, "Insufficient ETH sent");
            if (msg.value > owed) {
                payable(msg.sender).transfer(msg.value - owed);
            }
        } else {
            require(IERC20(Schema.Currency.unwrap(currency)).transferFrom(msg.sender, address(this), owed), "Transfer failed");
        }

        _accountDelta(currency, int256(owed));
    }
}

interface ILockCallback {
    function lockAcquired(address caller, bytes calldata data) external returns (bytes memory);
}