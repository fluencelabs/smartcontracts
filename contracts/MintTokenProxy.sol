pragma solidity ^0.4.18;

import './Mintable.sol';

// Used only for testing
contract MintTokenProxy {
    Mintable token;

    function setToken(address _token) public {
        token = Mintable(_token);
    }

    function mint(address _to, uint256 _amount) public returns(bool) {
        return token.mint(_to, _amount);
    }
}
