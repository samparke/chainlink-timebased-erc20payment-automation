// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Payment} from "../src/Payment.sol";
import {PayToken} from "../src/PayToken.sol";

contract DeployPay is Script {
    function run() external returns (PayToken, Payment) {
        uint256 deployerKey;
        if (block.chainid == 31337) {
            // anvil
            deployerKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployerKey);
        PayToken payToken = new PayToken();
        Payment paymentContract = new Payment(address(payToken));
        vm.stopBroadcast();
        return (payToken, paymentContract);
    }
}
