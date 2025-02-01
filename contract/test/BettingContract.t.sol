// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/BettingContract.sol";

contract BettingContractTest is Test {
    BettingContract public bettingContract;
    USDC public usdc;

    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    function setUp() public {
        vm.startPrank(owner);
        string[] memory agentNames = new string[](4);
        agentNames[0] = "Claude";
        agentNames[1] = "GPT-3.5";
        agentNames[2] = "DeepSeek";
        agentNames[3] = "Perplexity";

        bettingContract = new BettingContract(agentNames, 7 days);
        usdc = USDC(bettingContract.usdcToken());
        vm.stopPrank();

        // Use faucet to distribute USDC to users
        vm.prank(user1);
        usdc.faucet();
        vm.prank(user2);
        usdc.faucet();
    }

    // function testFaucet() public {
    //     uint256 initialBalance = usdc.balanceOf(user1);
    //     vm.prank(user1);
    //     vm.expectRevert("Faucet cooldown not expired");
    //     usdc.faucet();

    //     vm.warp(block.timestamp + 1 days);
    //     vm.prank(user1);
    //     usdc.faucet();

    //     assertEq(usdc.balanceOf(user1), initialBalance + 1000 * 10**6);
    // }

    function testPlaceBet() public {
        vm.startPrank(user1);
        usdc.approve(address(bettingContract), 100 * 10**6);
        bettingContract.placeBet(0, 100 * 10**6);
        vm.stopPrank();

        assertEq(bettingContract.totalBets(0), 100 * 10**6);
    }

    function testEndGameAndClaimRewards() public {
        // Place bets
        vm.startPrank(user1);
        usdc.approve(address(bettingContract), 100 * 10**6);
        bettingContract.placeBet(0, 100 * 10**6);
        vm.stopPrank();

        vm.startPrank(user2);
        usdc.approve(address(bettingContract), 200 * 10**6);
        bettingContract.placeBet(1, 200 * 10**6);
        vm.stopPrank();

        // End the game
        vm.warp(block.timestamp + 7 days);
        vm.prank(owner);
        bettingContract.endGame(0);

        // Claim rewards
        vm.prank(user1);
        bettingContract.claimRewards();

        // Check rewards
        assertEq(usdc.balanceOf(user1), 1285 * 10**6); // 1000 (initial) + 285 (95% of 300)
    }
}