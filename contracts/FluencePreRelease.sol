pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import './FluenceToken.sol';

interface Certifier {
    function certified(address _who) constant returns (bool);
}

contract FluencePreRelease is Ownable {
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
    }

    function presetReleased(address _to, uint256 amount) onlyOwner public {
        require(!releasingEnabled);
        released[_to] = amount;
    }

    function enableReleasing() onlyOwner public {
        releasingEnabled = true;
    }

    function disableReleasing() onlyOwner public {
        releasingEnabled = false;
    }

    function release() public returns(uint256 amount) {
        require(releasingEnabled);
        // check if verified
        require(certifier.certified(msg.sender));
        // check fpt balance
        // subtract $released
        amount = preSale.balanceOf(msg.sender).sub(released[msg.sender]);
        // issue tokens
        released[msg.sender] = amount;
        token.mint(msg.sender, amount);
    }

}