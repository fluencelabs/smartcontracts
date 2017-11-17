pragma solidity ^0.4.18;


import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract RenameableSymbol is Ownable {
    string public name;

    string  public symbol;

    function RenameableSymbol(string _symbol, string _name) public {
        name = _name;
        symbol = _symbol;
    }

    function rename(string _symbol, string _name) onlyOwner public {
        name = _name;
        symbol = _symbol;
    }
}
