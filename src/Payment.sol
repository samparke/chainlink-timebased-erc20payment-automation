// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PayToken} from "./PayToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Payment is Ownable {
    // errors
    error PayToken__UserAlreadyBeingPaid(address user);
    error PayToken__FailedPayment();

    // events
    event UserPaid(address user, uint256 amount);
    event UserAddedToPaymentList(address user);

    PayToken public immutable i_payToken;
    mapping(address user => uint256 balance) private s_userTokenBalance;
    mapping(address user => uint256 amount) private s_amountToPayUsers;
    address[] private usersToPay;

    constructor(PayToken _payToken) Ownable(msg.sender) {
        i_payToken = _payToken;
    }

    function addUserToPaymentList(address _user) external onlyOwner {
        for (uint256 i = 0; i < usersToPay.length; i++) {
            if (_user == usersToPay[i]) {
                revert PayToken__UserAlreadyBeingPaid(_user);
            }
        }
        usersToPay.push(_user);
        emit UserAddedToPaymentList(_user);
    }

    function payUsers() external {
        for (uint256 i = 0; i < usersToPay.length; i++) {
            bool success = i_payToken.mint(usersToPay[i], s_amountToPayUsers[usersToPay[i]]);
            if (!success) {
                revert PayToken__FailedPayment();
            }
            emit UserPaid(usersToPay[i], s_amountToPayUsers[usersToPay[i]]);
        }
    }

    // getter functions

    function getUserTokenBalance(address _user) external view returns (uint256) {
        return s_userTokenBalance[_user];
    }

    function getToken() external view returns (PayToken) {
        return i_payToken;
    }

    function getIsUserInPaymentList(address _user) external view returns (bool) {
        for (uint256 i = 0; i < usersToPay.length; i++) {
            if (_user == usersToPay[i]) {
                return true;
            }
        }
        return false;
    }
}
