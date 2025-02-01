// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/BettingContract.sol";

contract DeployBettingContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string[] memory agentNames = new string[](4);
        agentNames[0] = "Claude";
        agentNames[1] = "GPT-3.5";
        agentNames[2] = "DeepSeek";
        agentNames[3] = "Perplexity";

        uint256 bettingDuration = 7 days;

        BettingContract bettingContract = new BettingContract(agentNames, bettingDuration);

        // Use faucet to get some initial USDC for the deployer
        USDC(bettingContract.usdcToken()).faucet();
        
        console.log("BettingContract deployed at:", address(bettingContract));
        console.log("USDC token address:", address(bettingContract.usdcToken()));
        vm.stopBroadcast();
    }
}