pragma solidity ^0.4.18;


import './RenameableSymbol.sol';
import 'zeppelin-solidity/contracts/token/BurnableToken.sol';


contract FluenceToken is BurnableToken, RenameableSymbol("FPT(U)", "Fluence Presale Token (Unlocked)") {

    function FluenceToken(uint256 allocation) {
        totalSupply = allocation;
        balances[owner] = allocation;
    }

    uint   public constant decimals = 18;

}
