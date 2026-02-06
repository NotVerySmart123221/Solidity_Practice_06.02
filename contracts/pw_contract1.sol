// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

import "hardhat/console.sol";

interface IQuest {
    function startQuest(uint questId) external;
    function completeQuest(uint questId) external;
    function getReward(uint questId) external view returns (uint);
}

contract LevelSystem {
    address public owner;
    mapping(address => uint) public playerLevel;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function getLevelInfo() public virtual pure returns (string memory) {
        return "Base Level System";
    }
}

contract QuestManager is IQuest, LevelSystem {
    
    struct Quest {
        uint rewardAmount;
        uint requiredLevel;
    }

    struct PlayerProgress {
        bool isDoingQuest;
        uint currentQuestId;
        uint completedQuests;
    }

    mapping(uint => Quest) public quests;
    mapping(address => PlayerProgress) public players;

    constructor() {
        quests[1] = Quest(0.1 ether, 0);
        quests[2] = Quest(0.5 ether, 5);
    }

    function addQuest(uint _id, uint _reward, uint _level) external onlyOwner {
        quests[_id] = Quest(_reward, _level);
        console.log("New quest added. ID: %d, Reward: %d", _id, _reward);
    }

    function startQuest(uint _questId) external override {
        Quest memory q = quests[_questId];
        require(playerLevel[msg.sender] >= q.requiredLevel, "level too low");
        require(!players[msg.sender].isDoingQuest, "finish current quest first");

        players[msg.sender].isDoingQuest = true;
        players[msg.sender].currentQuestId = _questId;

        console.log("player %s started quest %d", msg.sender, _questId);
    }

    function completeQuest(uint _questId) external override {
        PlayerProgress storage p = players[msg.sender];
        p.isDoingQuest = false;
        p.completedQuests++;
        playerLevel[msg.sender] += 1;

        console.log("quest %d completed! new level: %d", _questId, playerLevel[msg.sender]);
    }

    function getReward(uint _questId) external view override returns (uint) {
        uint reward = quests[_questId].rewardAmount;
        require(reward > 0, "No reward for this quest");
        
        console.log("Reward issued: %d", reward);
        return reward;
    }

    function getLevelInfo() public override pure returns (string memory) {
        return "advanced quest-based level system";
    }

    receive() external payable {
        console.log("fund refilled by: %d", msg.value);
    }
}