// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {ZkMinimalAccount} from "../../src/zksync/ZkMinimalAccount.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {
    Transaction,
    MemoryTransactionHelper
} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract ZkMinimalAccountTest is Test {
    using MessageHashUtils for bytes32;
    //VARIABLES

    ZkMinimalAccount zkMinimalAccount;
    ERC20Mock usdc;

    //CONSTANTS
    uint256 constant AMOUNT_TO_MINT = 1e18;
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 constant EMPTY_BYTES32 = bytes32(0);

    function setUp() public {
        zkMinimalAccount = new ZkMinimalAccount();
        usdc = new ERC20Mock();
        zkMinimalAccount.transferOwnership(ANVIL_DEFAULT_ACCOUNT);
    }

    function testZkOwnerCanExecuteCommands() public {
        //Arrange
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(zkMinimalAccount), AMOUNT_TO_MINT);

        Transaction memory unsignedTx = _createUnsignedTransaction(address(zkMinimalAccount), 113, dest, value, data);

        //Act
        vm.prank(zkMinimalAccount.owner());
        zkMinimalAccount.executeTransaction(EMPTY_BYTES32, EMPTY_BYTES32, unsignedTx);

        //Assert
        assertEq(usdc.balanceOf(address(zkMinimalAccount)), AMOUNT_TO_MINT);
    }

    function testZkValidateTransaction() public {
        //Arrange
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSelector(ERC20Mock.mint.selector, address(zkMinimalAccount), AMOUNT_TO_MINT);

        Transaction memory unsignedTx = _createUnsignedTransaction(address(zkMinimalAccount), 113, dest, value, data);
        //Act

        //Assert
    }

    //HELPER FUNCTIONS
    function _signTransaction(Transaction memory transaction) internal view returns (Transaction memory) {
        bytes32 unsignedTxHash = MemoryTransactionHelper.encodeHash(transaction);

        //We are signing the txHash
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, unsignedTxHash);
        //Setting up the transaction struct with the signature
        Transaction memory signedTx = transaction;
        signedTx.signature = abi.encodePacked(r, s, v);
        //Return the signed transaction
        return signedTx;
    }

    function _createUnsignedTransaction(
        address from,
        uint8 transactionType,
        address to,
        uint256 value,
        bytes memory data
    ) internal view returns (Transaction memory) {
        uint256 nonce = vm.getNonce(address(zkMinimalAccount));
        bytes32[] memory factoryDeps = new bytes32[](0);

        return Transaction({
            txType: transactionType, //type 113
            from: uint256(uint160(from)),
            to: uint256(uint160(to)),
            gasLimit: 16777216,
            gasPerPubdataByteLimit: 16777216,
            maxFeePerGas: 16777216,
            maxPriorityFeePerGas: 16777216,
            paymaster: 0,
            nonce: nonce,
            value: value,
            reserved: [uint256(0), uint256(0), uint256(0), uint256(0)],
            data: data,
            signature: hex"",
            factoryDeps: factoryDeps,
            paymasterInput: hex"",
            reservedDynamic: hex""
        });
    }
}
