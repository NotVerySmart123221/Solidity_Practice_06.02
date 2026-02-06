// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 < 0.9.0;

// call -> read, write, payable
// delegatecall -> read, write, payable (Змінює стан контракту який робить виклик, функціями іншого)
// staticcall -> read
// interface_call

interface IContractA {
    function set_value(uint n_value) external;
    function get_value() external view returns(uint);
    function pay() external payable returns(string memory);
}


contract ContractA{
    uint value; // 0
    address contract_address;//1
    address owner;//2

    function set_value(uint n_value) external{
        owner = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        value = n_value;
    }

    function get_value() external view returns(uint){
        return value;
    }

    function pay() external payable returns(string memory){
        return "Thanks";
    }
}

contract ContractB{
    uint public value; // 0
    address public contract_a; // 1
    address owner; // 2
    
    modifier isOwner(){
        require(msg.sender == owner, "You're not owner");
        _;
    }

    constructor(address other_contract){
        contract_a = other_contract;
        owner = msg.sender;        
    }

    function only_owner() public isOwner view returns(string memory){
        return "Success";
    }

    function callSetValue(uint n_value) public returns(uint){
        // ABI - Application Binnary Interface
        // set_value(uint256)
        // call - > (bool call_result, bytes result_data)
        (bool result, ) = contract_a.call(abi.encodeWithSignature("set_value(uint256)", n_value));
        require(result, "Contract calling error: set_value");

        (bool result2, bytes memory return_data) = contract_a.call(abi.encodeWithSignature("get_value()"));
        require(result2, "Contract calling error: get_value");
        return abi.decode(return_data, (uint));
    }

    function callPayable() public payable returns(string memory){
        (bool result, bytes memory return_data) = contract_a.call{value: msg.value}(abi.encodeWithSignature("pay()"));
        require(result,"Contract calling error");
        return abi.decode(return_data, (string));
    }

    function delegateSetValue(uint n_value) public returns(uint){
        // ABI - Application Binnary Interface
        // set_value(uint256)
        // call - > (bool call_result, bytes result_data)
        (bool result, ) = contract_a.delegatecall(abi.encodeWithSignature("set_value(uint256)", n_value));
        require(result, "Contract calling error: set_value");

        // (bool result2, bytes memory return_data) = contract_a.delegatecall(abi.encodeWithSignature("get_value()"));
        // require(result2, "Contract calling error: get_value");
        // return abi.decode(return_data, (uint));
        return 1;
    }

    function static_call() public view returns(uint){
        (bool result, bytes memory return_data) = contract_a.staticcall(abi.encodeWithSignature("get_value()"));
        require(result,"Contract calling error");
        return abi.decode(return_data, (uint));
    }
    
    function interface_call(uint n_value) public returns(uint){
        IContractA(contract_a).set_value(n_value);
        return IContractA(contract_a).get_value();
    }

    function payable_interface_call() public payable returns(string memory){
        return IContractA(contract_a).pay{value: msg.value}();
    }
}
