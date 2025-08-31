// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {MinimalAccount} from "../../src/ethereum/MinimalAccount.sol";
import {DeployMinimal} from "../../script/DeployMinimal.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, PackedUserOperation} from "../../script/SendPackedUserOp.s.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32;

    MinimalAccount minimalAccount;
    HelperConfig config;
    ERC20Mock usdc;
    SendPackedUserOp sendPackedUserOp;

    address randomUser = makeAddr("randomeUser");

    uint256 constant AMOUNT_TO_MINT = 1e18;

    function setUp() public {
        DeployMinimal deployer = new DeployMinimal();
        (config, minimalAccount) = deployer.deployMinimalAccount();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
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

    function testRecoverSignedOp() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT_TO_MINT);
        bytes memory executeCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, data);
        PackedUserOperation memory userOp = sendPackedUserOp.generatePackedUserOp(executeCallData, config.getConfig());
        bytes32 userOpHash = IEntryPoint(config.getConfig().entryPoint).getUserOpHash(userOp);

        //Act
        address actualSigner = ECDSA.recover(userOpHash.toEthSignedMessageHash(), userOp.signature);

        //Assert
        assertEq(actualSigner, minimalAccount.owner());
    }

    function testValidationOfUserOps() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT_TO_MINT);
        bytes memory executeCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, data);
        PackedUserOperation memory userOp = sendPackedUserOp.generatePackedUserOp(executeCallData, config.getConfig());
        bytes32 userOpHash = IEntryPoint(config.getConfig().entryPoint).getUserOpHash(userOp);
        uint256 missingAccountFunds = 1e18;

        //Act
        vm.prank(config.getConfig().entryPoint);
        uint256 validationData = minimalAccount.validateUserOp(userOp, userOpHash, missingAccountFunds);

        //Assert
        assertEq(validationData, 0);
    }

    function testEntryPointCanExecuteCommands() public {
        //Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT_TO_MINT);
        bytes memory executeCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, data);
        PackedUserOperation memory userOp = sendPackedUserOp.generatePackedUserOp(executeCallData, config.getConfig());
        bytes32 userOpHash = IEntryPoint(config.getConfig().entryPoint).getUserOpHash(userOp);

        vm.deal(address(minimalAccount), 1e18);

        //Act

        //Assert
    }
}
