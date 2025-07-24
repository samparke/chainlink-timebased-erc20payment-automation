// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Payment} from "../src/Payment.sol";
import {PayToken} from "../src/PayToken.sol";

contract InteractPay is Script {
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    address paymentContractAddress = 0xF0268aAd440F844609275b756A4C58760B9C8BA4;
    address payToken = 0x95cBa7FDd51a0cD989c5caEDbDd44b2Dc329Cabd;

    function run() public {
        vm.startBroadcast(deployerKey);
        // Payment paymentContract = Payment();
        vm.stopBroadcast();
    }
}
