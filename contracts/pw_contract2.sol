// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

import "hardhat/console.sol";

library ResourceUtils {
    
    function calculateUpgradeCost(uint baseCost, uint currentLevel) internal pure returns (uint) {
        return baseCost * (2 ** currentLevel);
    }

    function applyDiscount(uint amount, uint discountPercent) internal pure returns (uint) {
        return amount - (amount * discountPercent / 100);
    }

    function calculateEnergyRecovery(uint lastActionTimestamp, uint recoveryRate) internal view returns (uint) {
        uint timePassed = block.timestamp - lastActionTimestamp;
        return timePassed * recoveryRate;
    }
}

contract ResourceManager {
    using ResourceUtils for uint;

    struct Player {
        uint gold;
        uint energy;
        uint lastEnergyUpdate;
        uint swordLevel;
    }

    mapping(address => Player) public players;
    uint public constant BASE_UPGRADE_COST = 100;

    event Upgraded(address indexed player, uint newLevel, uint cost);
    event EnergyRefilled(address indexed player, uint amount);

    constructor() {
        console.log("resourceManager deployed");
    }

    function joinGame() external {
        require(players[msg.sender].lastEnergyUpdate == 0);
        players[msg.sender] = Player(1000, 100, block.timestamp, 0);
    }

    function upgradeSword() external {
        Player storage p = players[msg.sender];
        
        uint cost = BASE_UPGRADE_COST.calculateUpgradeCost(p.swordLevel);
        
        uint finalCost = cost.applyDiscount(10);

        require(p.gold >= finalCost, "not enough gold");

        p.gold -= finalCost;
        p.swordLevel++;

        console.log("sword upgraded to level %d for %d gold", p.swordLevel, finalCost);
        emit Upgraded(msg.sender, p.swordLevel, finalCost);
    }

    function refreshEnergy() external {
        Player storage p = players[msg.sender];
        
        uint recovered = ResourceUtils.calculateEnergyRecovery(p.lastEnergyUpdate, 5);
        
        p.energy += recovered;
        p.lastEnergyUpdate = block.timestamp;

        console.log("energy recovered: %d. total: %d", recovered, p.energy);
        emit EnergyRefilled(msg.sender, p.energy);
    }

    function getPlayerData(address _addr) external view returns (uint, uint, uint) {
        Player memory p = players[_addr];
        return (p.gold, p.energy, p.swordLevel);
    }
}