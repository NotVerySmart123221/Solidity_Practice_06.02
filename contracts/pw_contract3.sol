// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

import "hardhat/console.sol";

contract WarriorGuild {
    struct Warrior {
        string name;
        uint level;
        string className;
    }

    mapping(address => Warrior) public members;
    address[] public membersList;

    event WarriorRegistered(address indexed warrior, string name, string className);

    function register(string memory _name, string memory _class) internal {
        require(bytes(members[msg.sender].name).length == 0);
        
        members[msg.sender] = Warrior(_name, 1, _class);
        membersList.push(msg.sender);
        
        emit WarriorRegistered(msg.sender, _name, _class);
    }

    function attack() public virtual view returns (string memory, uint) {
        return ("Basic Attack", 10);
    }
}

contract Knight is WarriorGuild {
    function join(string memory _name) external {
        register(_name, "Knight");
        console.log("knight %s joined the guild!", _name);
    }

    function attack() public override pure returns (string memory, uint) {
        return ("Sword Slash", 25);
    }
}

contract Mage is WarriorGuild {
    function join(string memory _name) external {
        register(_name, "Mage");
    }

    function attack() public override view returns (string memory, uint) {
        uint spellPower = (block.timestamp % 2 == 0) ? 50 : 15;
        return ("Fireball", spellPower);
    }
}

contract Assassin is WarriorGuild {
    function join(string memory _name) external {
        register(_name, "Assassin");
    }

    function attack() public override view returns (string memory, uint) {
        uint damage = 20;
        if (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10 > 7) {
            damage = 100;
            console.log("critical hit!");
        }
        return ("Dagger Stab", damage);
    }
}