// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract MockFailToken is ERC20, ERC20Burnable, Ownable, AccessControl {
    error PayToken__BalanceMustBeMoreThanBurnAmount();
    error PayToken__MustBeMoreThanZero();

    modifier moreThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert PayToken__MustBeMoreThanZero();
        }
        _;
    }

    bytes32 public constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE");

    constructor() ERC20("PayToken", "PAY") Ownable(msg.sender) {
        grantMintAndBurnRole(msg.sender);
    }

    function grantMintAndBurnRole(address _account) public onlyOwner {
        _grantRole(MINT_AND_BURN_ROLE, _account);
    }

    function mint(address _user, uint256 _amount)
        public
        moreThanZero(_amount)
        onlyRole(MINT_AND_BURN_ROLE)
        returns (bool)
    {
        _mint(_user, _amount);
        return false;
    }

    function burn(uint256 _amount) public override onlyOwner moreThanZero(_amount) onlyRole(MINT_AND_BURN_ROLE) {
        uint256 balance = balanceOf(msg.sender);
        if (balance < _amount) {
            revert PayToken__BalanceMustBeMoreThanBurnAmount();
        }
        super.burn(_amount);
    }
}
