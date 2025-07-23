// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Payment} from "../src/Payment.sol";
import {PayToken} from "../src/PayToken.sol";
import {Test} from "forge-std/Test.sol";

contract PaymentTest is Test {
    PayToken token;
    Payment paymentContract;
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        token = new PayToken();
        paymentContract = new Payment(token);
    }

    function testAdduserToPaymentList(address _user) public {
        paymentContract.addUserToPaymentList(_user);
        assertTrue(paymentContract.getIsUserInPaymentList(_user));
    }
}
