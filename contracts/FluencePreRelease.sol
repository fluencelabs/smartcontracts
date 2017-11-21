pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './Haltable.sol';

interface Certifier {
    function certified(address _who) constant returns (bool);
}

contract FluencePreRelease is Haltable, Destructible {
    using SafeMath for uint256;

    mapping(address => uint256) public released;

    address public certifier;
    address public preSale;
    address public token;

    function FluencePreRelease(address _certifier, address _preSale, address _token) {
        require(_certifier != address(0x0));
        require(_preSale != address(0x0));
        require(_token != address(0x0));

        certifier = _certifier;
        preSale = _preSale;
        token = _token;

        // Halt initially
        halted = true;
    }

    function setCertifier(address _certifier) onlyOwner public {
        require(_certifier != address(0x0));
        certifier = _certifier;
    }

    function setToken(address _token) onlyOwner public {
        require(_token != address(0x0));
        token = _token;
    }

    function presetReleased(address _to, uint256 amount) onlyOwner onlyInEmergency public {
        released[_to] = amount;
    }

    function release(address _holder) public stopInEmergency returns(uint256 amount) {
        address beneficiary = _holder;
        if(beneficiary == address(0x0)) beneficiary = msg.sender;
        // check if verified
        require(Certifier(certifier).certified(beneficiary));

        address source = msg.sender;
        // check fpt balance
        // subtract $released
        amount = ERC20Basic(preSale).balanceOf(source).sub(released[source]);
        // issue tokens
        released[source] = released[source].add(amount);
        assert(released[source] == ERC20Basic(preSale).balanceOf(source));

        ERC20Basic(token).transfer(beneficiary, amount);
    }

}