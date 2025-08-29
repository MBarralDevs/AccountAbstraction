// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {MinimalAccount} from "../../src/ethereum/MinimalAccount.sol";
import {DeployMinimal} from "../../script/DeployMinimal.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract MinimalAccountTest is Test {
    MinimalAccount minimalAccount;
    HelperConfig config;
    ERC20Mock usdc;

    address randomUser = makeAddr("randomeUser");

    uint256 constant AMOUNT_TO_MINT = 1e18;

    function setUp() public {
        DeployMinimal deployer = new DeployMinimal();
        (config, minimalAccount) = deployer.deployMinimalAccount();
        usdc = new ERC20Mock();
    }

    function testOwnerCanExecuteCommands() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT_TO_MINT);
        //Act
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, data);
        //Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT_TO_MINT);
    }

    function testNonOwnerCannotExecuteCommands() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT_TO_MINT);
        //Act
        vm.prank(randomUser);
        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        minimalAccount.execute(dest, value, data);
    }
}
