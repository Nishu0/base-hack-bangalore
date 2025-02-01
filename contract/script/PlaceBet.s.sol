// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/BettingContract.sol";

contract PlaceBet is Script {
    function run() external {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        address contractAddress = vm.envAddress("BETTING_CONTRACT_ADDRESS");
        
        vm.startBroadcast(userPrivateKey);

        BettingContract bettingContract = BettingContract(contractAddress);
        USDC usdc = USDC(bettingContract.usdcToken());

        // Use faucet to get some USDC
        usdc.faucet();

        // Approve USDC spending
        usdc.approve(address(bettingContract), 100 * 10**6); // Approve 100 USDC

        // Place bet on agent index 0 (Claude) with 100 USDC
        bettingContract.placeBet(0, 100 * 10**6);

        vm.stopBroadcast();
    }
}