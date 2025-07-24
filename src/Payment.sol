// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PayToken} from "./PayToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract Payment is Ownable, ReentrancyGuard, AccessControl {
    // errors
    error Payment__UserAlreadyBeingPaid(address user);
    error Payment__FailedPayment();

    // events
    event UserPaid(address user, uint256 amount);
    event UserAddedToPaymentList(address user);

    PayToken public immutable i_payToken;
    mapping(address user => uint256 balance) private s_userTokenBalance;
    mapping(address user => uint256 amount) private s_amountToPayUsers;
    address[] private usersToPay;
    bytes32 public constant PAY_USER_ROLE = keccak256("PAY_USER_ROLE");

    constructor(address _payToken) Ownable(msg.sender) {
        i_payToken = PayToken(_payToken);
        grantPaymentRole(msg.sender);
    }

    function grantPaymentRole(address _account) public onlyOwner {
        _grantRole(PAY_USER_ROLE, _account);
    }

    function addUserToPaymentList(address _user, uint256 _amountToPay) external onlyOwner {
        for (uint256 i = 0; i < usersToPay.length; i++) {
            if (_user == usersToPay[i]) {
                revert Payment__UserAlreadyBeingPaid(_user);
            }
        }
        usersToPay.push(_user);
        s_amountToPayUsers[_user] = _amountToPay;
        emit UserAddedToPaymentList(_user);
    }

    function payUsers() external nonReentrant onlyRole(PAY_USER_ROLE) {
        for (uint256 i = 0; i < usersToPay.length; i++) {
            bool success = i_payToken.mint(usersToPay[i], s_amountToPayUsers[usersToPay[i]]);
            if (!success) {
                revert Payment__FailedPayment();
            }
            emit UserPaid(usersToPay[i], s_amountToPayUsers[usersToPay[i]]);
        }
    }

    // getter functions

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
