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

    /**
     * @notice this function is to grant accounts to call the payUsers function, which mints tokens on the PayToken contract.
     * Specifically, this will be used to grant Chainlink Upkeep to call the functions in an automated fashion
     * @param _account the account we are granting access to for calling payUsers functions
     */
    function grantPaymentRole(address _account) public onlyOwner {
        _grantRole(PAY_USER_ROLE, _account);
    }

    /**
     * @notice adds users to payment list, which when payUsers gets called, mints tokens to these addresses
     * @param _user the user we are adding to the payment list
     * @param _amountToPay the amount we are going to pay users (which will be translated in erc20 tokens)
     */
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

    /**
     * @notice pays users by minting tokens from the pay token contract
     */
    function payUsers() external nonReentrant onlyRole(PAY_USER_ROLE) {
        for (uint256 i = 0; i < usersToPay.length; i++) {
            address user = usersToPay[i];
            uint256 amount = s_amountToPayUsers[usersToPay[i]];

            if (amount == 0) {
                continue;
            }

            bool success = i_payToken.mint(user, amount);
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
