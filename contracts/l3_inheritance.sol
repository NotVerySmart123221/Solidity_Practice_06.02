// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 < 0.9.0;

import "hardhat/console.sol";

contract Parent{
    /*
    public
    private
    internal
    external
    */
    uint private private_field = 12;
    string internal message = "Hello from parent";

    function method() public virtual pure returns(string memory){
        return "Parent";
    }
    
    function get_state() public virtual view returns(string memory, string memory){
        return("Parent", message);
    }
}

contract Child is Parent{
    function get_message() public view returns(string memory){
        return message;
    }
    function get_state() public override view returns(string memory, string memory){
        return("Child", message);
    }
    // function get_private_field() public view returns(uint){
    //     return private_field;
    // }
}

abstract contract Token{
    uint internal field = 100;
    function mint() public pure virtual returns(uint);

    function method() public virtual pure returns(string memory){
        return "Token";
    }
}

contract AwesomeToken is Token, Parent{
    function mint() public pure override returns(uint){
        console.log("AwesomeToken minting");
        return 1000000000000000000000000000;
    }
    function get_message() public view returns(string memory){
        return message;
    }
    function get_field() public view returns(uint){
        return field;
    }
    function method() public override(Token, Parent) pure returns(string memory){
        console.log(Token.method());
        console.log(Parent.method());
        
        return "AwesomeToken";
    }
}