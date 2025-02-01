// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDC is ERC20 {
    constructor(uint256 initialSupply) ERC20("USDC Testnet", "USDC") {
        _mint(msg.sender, initialSupply);
    }
}

contract BettingContract is Ownable(msg.sender) {
    USDC public usdcToken;
    uint256 public bettingEndTime;
    uint256 public constant PROTOCOL_FEE = 5; // 5% fee

    struct Agent {
        string name;
        uint256 betsPlaced;
    }

    Agent[] public agents;
    mapping(address => mapping(uint256 => uint256)) public userBets;
    mapping(uint256 => uint256) public totalBets;
    bool public gameEnded;
    uint256 public winningAgentIndex;

    event BetPlaced(address user, uint256 agentIndex, uint256 amount);
    event GameEnded(uint256 winningAgentIndex);
    event RewardsClaimed(address user, uint256 amount);

    constructor(string[] memory _agentNames, uint256 _bettingDuration) {
        for (uint256 i = 0; i < _agentNames.length; i++) {
            agents.push(Agent(_agentNames[i], 0));
        }
        bettingEndTime = block.timestamp + _bettingDuration;
        usdcToken = new USDC(1000000 * 10**6); // 1 million USDC
    }

    function placeBet(uint256 _agentIndex, uint256 _amount) external {
        require(block.timestamp < bettingEndTime, "Betting period has ended");
        require(_agentIndex < agents.length, "Invalid agent index");
        require(usdcToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        userBets[msg.sender][_agentIndex] += _amount;
        totalBets[_agentIndex] += _amount;
        agents[_agentIndex].betsPlaced += _amount;

        emit BetPlaced(msg.sender, _agentIndex, _amount);
    }

    function endGame(uint256 _winningAgentIndex) external onlyOwner {
        require(block.timestamp >= bettingEndTime, "Betting period not yet ended");
        require(_winningAgentIndex < agents.length, "Invalid winning agent index");
        require(!gameEnded, "Game already ended");

        gameEnded = true;
        winningAgentIndex = _winningAgentIndex;

        emit GameEnded(_winningAgentIndex);
    }

    function claimRewards() external {
        require(gameEnded, "Game not yet ended");
        uint256 userBet = userBets[msg.sender][winningAgentIndex];
        require(userBet > 0, "No winning bets");

        uint256 totalWinningBets = totalBets[winningAgentIndex];
        uint256 totalPrizePool = usdcToken.balanceOf(address(this));
        uint256 userReward = (userBet * totalPrizePool * (100 - PROTOCOL_FEE)) / (totalWinningBets * 100);

        userBets[msg.sender][winningAgentIndex] = 0;
        require(usdcToken.transfer(msg.sender, userReward), "Reward transfer failed");

        emit RewardsClaimed(msg.sender, userReward);
    }

    function withdrawProtocolFees() external onlyOwner {
        require(gameEnded, "Game not yet ended");
        uint256 totalPrizePool = usdcToken.balanceOf(address(this));
        uint256 protocolFees = (totalPrizePool * PROTOCOL_FEE) / 100;
        require(usdcToken.transfer(owner(), protocolFees), "Fee transfer failed");
    }
}