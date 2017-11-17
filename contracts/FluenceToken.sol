pragma solidity ^0.4.18;


import './Mintable.sol';
import './RenameableSymbol.sol';


contract FluenceToken is Mintable, RenameableSymbol("FPT(U)", "Fluence Presale Token (Unlocked)") {

    uint   public constant decimals = 18;

}
