// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {ZkMinimalAccount} from "../../src/zksync/ZkMinimalAccount.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract ZkMinimalAccountTest is Test {
    //VARIABLES
    ZkMinimalAccount zkMinimalAccount;
    ERC20Mock usdc;

    //CONSTANTS
    uint256 constant AMOUNT_TO_MINT = 1e18;

    function setUp() public {
        zkMinimalAccount = new ZkMinimalAccount();
        usdc = new ERC20Mock();
    }

    function testZkOwnerCanExecuteCommands() public {
        //Arrange
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(zkMinimalAccount), AMOUNT_TO_MINT);

        //Act

        //Assert
    }
}
