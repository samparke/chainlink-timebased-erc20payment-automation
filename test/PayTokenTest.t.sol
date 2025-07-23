// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {PayToken} from "../src/PayToken.sol";

contract PayTokenTest is Test {
    PayToken token;

    function setUp() public {
        token = new PayToken();
    }

    function testBurnBalanceMustBeMoreThanAmountRevert() public {
        vm.expectRevert(PayToken.PayToken__BalanceMustBeMoreThanBurnAmount.selector);
        token.burn(1 ether);
    }

    function testMintAndThenBurnAmount() public {
        token.mint(address(this), 1 ether);
        uint256 balanceAfterMint = token.balanceOf(address(this));
        token.burn(1 ether);
        uint256 balanceAfterBurn = token.balanceOf(address(this));
        assertEq(balanceAfterMint, 1 ether);
        assertEq(balanceAfterBurn, 0);
    }

    function testMustbeMoreThanZeroMintRevert() public {
        vm.expectRevert(PayToken.PayToken__MustBeMoreThanZero.selector);
        token.mint(address(this), 0);
    }

    function testMustbeMoreThanZeroBurnRevert() public {
        token.mint(address(this), 1 ether);
        vm.expectRevert(PayToken.PayToken__MustBeMoreThanZero.selector);
        token.burn(0);
    }
}
