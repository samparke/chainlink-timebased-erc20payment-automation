// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract PayToken is ERC20, ERC20Burnable, Ownable {
    error PayToken__BalanceMustBeMoreThanBurnAmount();
    error PayToken__MustBeMoreThanZero();

    modifier moreThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert PayToken__MustBeMoreThanZero();
        }
        _;
    }

    constructor() ERC20("PayToken", "PAY") Ownable(msg.sender) {}

    function mint(address _user, uint256 _amount) external onlyOwner moreThanZero(_amount) returns (bool) {
        _mint(_user, _amount);
        return true;
    }

    function burn(uint256 _amount) public override onlyOwner moreThanZero(_amount) {
        uint256 balance = balanceOf(msg.sender);
        if (balance < _amount) {
            revert PayToken__BalanceMustBeMoreThanBurnAmount();
        }
        super.burn(_amount);
    }
}
