// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    //ERRORS
    error HelperConfig__InvalidChainId();

    //STRUCTS
    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    //VARIABLES
    uint256 constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant ARBITRUM_MAINNET_CHAIN_ID = 42_161;
    uint256 constant ZKSYNC_MAINNET_CHAIN_ID = 324;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant BURNER_WALLET = 0x8ffA18f05056458dbFB2f7A122F185878B2d6e2f;

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].entryPoint != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789, account: BURNER_WALLET});
    }

    function getZkSyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET});
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.entryPoint != address(0)) {
            return localNetworkConfig;
        }

        //Deploy a mock entry point contract
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        // ERC20Mock erc20Mock = new ERC20Mock();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({entryPoint: address(entryPoint), account: ANVIL_DEFAULT_ACCOUNT});
        return localNetworkConfig;
    }
}
