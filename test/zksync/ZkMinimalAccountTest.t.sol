// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {ZkMinimalAccount} from "../../src/zksync/ZkMinimalAccount.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {Transaction} from
    "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";

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

    //HELPER FUNCTIONS
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
