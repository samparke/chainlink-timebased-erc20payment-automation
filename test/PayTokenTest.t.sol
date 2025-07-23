// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {PayToken} from "../src/PayToken.sol";

contract PayTokenTest is Test {
    PayToken token;

    function setUp() public {
        token = new PayToken();
    }
}
