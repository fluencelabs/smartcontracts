pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import './FluenceToken.sol';
import './Haltable.sol';

interface Certifier {
    function certified(address _who) constant returns (bool);
}

contract FluencePreRelease is Haltable {
    using SafeMath for uint256;

    bool public releasingEnabled = false;

    mapping(address => uint256) public released;

    Certifier private certifier;
    ERC20Basic private preSale;
    FluenceToken private token;

    function FluencePreRelease(address _certifier, address _preSale, address _token) {
        require(_certifier != address(0x0));
        certifier = Certifier(_certifier);

        require(_preSale != address(0x0));
        preSale = ERC20Basic(_preSale);

        require(_token != address(0x0));
        token = FluenceToken(_token);

        // Halt initially
        halted = true;
    }

    function setCertifier(address _certifier) onlyOwner public {
        require(_certifier != address(0x0));
        certifier = Certifier(_certifier);
    }

    function setToken(address _token) onlyOwner public {
        require(_token != address(0x0));
        token = FluenceToken(_token);
    }

    function destroy() onlyOwner onlyInEmergency public {
        selfdestruct(owner);
    }

    function presetReleased(address _to, uint256 amount) onlyOwner onlyInEmergency public {
        released[_to] = amount;
    }

    function release() public stopInEmergency returns(uint256 amount) {
        // check if verified
        require(certifier.certified(msg.sender));
        // check fpt balance
        // subtract $released
        amount = preSale.balanceOf(msg.sender).sub(released[msg.sender]);
        // issue tokens
        released[msg.sender] = released[msg.sender].add(amount);
        token.mint(msg.sender, amount);
    }

}