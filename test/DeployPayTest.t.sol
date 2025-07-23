// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Payment} from "../src/Payment.sol";
import {PayToken} from "../src/PayToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployPay} from "../script/DeployPay.s.sol";
import {MockFailToken} from "./mocks/MockFailToken.sol";

contract DeployPayTest is Test {
    DeployPay deployer;
    PayToken payToken;
    Payment paymentContract;
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address owner = makeAddr("owner");
    address anvil = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address sepolia = vm.addr(vm.envUint("PRIVATE_KEY"));
    address deployerAddress;

    function setUp() public {
        if (bytes(vm.envString("SEPOLIA_RPC_URL")).length > 0) {
            vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
            deployerAddress = sepolia;
        } else {
            deployerAddress = anvil;
        }
        deployer = new DeployPay();
        (payToken, paymentContract) = deployer.run();
    }

    function testAdduserToPaymentList() public {
        vm.prank(deployerAddress);
        paymentContract.addUserToPaymentList(user1, 1 ether);
        assertTrue(paymentContract.getIsUserInPaymentList(user1));
        assertFalse(paymentContract.getIsUserInPaymentList(user2));
    }

    function testGetpayToken() public view {
        assertEq(address(paymentContract.getToken()), address(payToken));
    }

    function testAddUsersToListAndPayUsersAndGetBalanceToSeeAnIncrease() public {
        vm.startPrank(deployerAddress);
        paymentContract.addUserToPaymentList(user1, 1 ether);
        paymentContract.addUserToPaymentList(user2, 2 ether);
        paymentContract.addUserToPaymentList(user3, 3 ether);

        // because the test contract is the msg.sender who deployed the payToken, it is the owner
        // we therefore need to grant the paymentContract minting and burning role
        payToken.grantMintAndBurnRole(address(paymentContract));

        paymentContract.payUsers();
        vm.stopPrank();

        uint256 user1Balance = payToken.balanceOf(user1);
        uint256 user2Balance = payToken.balanceOf(user2);
        uint256 user3Balance = payToken.balanceOf(user3);

        assertEq(user1Balance, payToken.balanceOf(user1));
        assertEq(user2Balance, payToken.balanceOf(user2));
        assertEq(user3Balance, payToken.balanceOf(user3));
    }

    function testAttemptToAddUserToPaymentListWhoIsAlreadyThere() public {
        vm.prank(deployerAddress);
        paymentContract.addUserToPaymentList(user1, 1 ether);
        vm.expectPartialRevert(Payment.Payment__UserAlreadyBeingPaid.selector);
        vm.prank(deployerAddress);
        paymentContract.addUserToPaymentList(user1, 1 ether);
    }

    function testGetIsUserInPaymentListIsFalse() public view {
        assertFalse(paymentContract.getIsUserInPaymentList(user1));
    }

    function testPaymentFail() public {
        MockFailToken mockpayToken = new MockFailToken();
        Payment mockPayment = new Payment(address(mockpayToken));
        mockpayToken.grantMintAndBurnRole(address(mockPayment));

        mockPayment.addUserToPaymentList(user1, 1 ether);
        vm.expectRevert(Payment.Payment__FailedPayment.selector);
        mockPayment.payUsers();
    }
}
