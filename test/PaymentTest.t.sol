// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Payment} from "../src/Payment.sol";
import {PayToken} from "../src/PayToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {MockFailToken} from "./mocks/MockFailToken.sol";

contract PaymentTest is Test {
    PayToken token;
    Payment paymentContract;
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address owner = makeAddr("owner");

    function setUp() public {
        token = new PayToken();
        paymentContract = new Payment(address(token));
    }

    function testAdduserToPaymentList() public {
        paymentContract.addUserToPaymentList(user1, 1 ether);
        assertTrue(paymentContract.getIsUserInPaymentList(user1));
        assertFalse(paymentContract.getIsUserInPaymentList(user2));
    }

    function testGetToken() public view {
        assertEq(address(paymentContract.getToken()), address(token));
    }

    function testAddUsersToListAndPayUsersAndGetBalanceToSeeAnIncrease() public {
        paymentContract.addUserToPaymentList(user1, 1 ether);
        paymentContract.addUserToPaymentList(user2, 2 ether);
        paymentContract.addUserToPaymentList(user3, 3 ether);

        // because the test contract is the msg.sender who deployed the token, it is the owner
        // we therefore need to grant the paymentContract minting and burning role
        token.grantMintAndBurnRole(address(paymentContract));

        paymentContract.payUsers();

        uint256 user1Balance = token.balanceOf(user1);
        uint256 user2Balance = token.balanceOf(user2);
        uint256 user3Balance = token.balanceOf(user3);

        assertEq(user1Balance, token.balanceOf(user1));
        assertEq(user2Balance, token.balanceOf(user2));
        assertEq(user3Balance, token.balanceOf(user3));
    }

    function testAttemptToAddUserToPaymentListWhoIsAlreadyThere() public {
        paymentContract.addUserToPaymentList(user1, 1 ether);
        vm.expectPartialRevert(Payment.Payment__UserAlreadyBeingPaid.selector);
        paymentContract.addUserToPaymentList(user1, 1 ether);
    }

    function testGetIsUserInPaymentListIsFalse() public view {
        assertFalse(paymentContract.getIsUserInPaymentList(user1));
    }

    function testPaymentFail() public {
        MockFailToken mockToken = new MockFailToken();
        Payment mockPayment = new Payment(address(mockToken));
        mockToken.grantMintAndBurnRole(address(mockPayment));

        mockPayment.addUserToPaymentList(user1, 1 ether);
        vm.expectRevert(Payment.Payment__FailedPayment.selector);
        mockPayment.payUsers();
    }
}
