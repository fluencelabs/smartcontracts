pragma solidity ^0.4.18;


contract FakeCertifier {
    function FakeCertifier(){

    }

    function certified(address _who) constant returns (bool) {
        return true;
    }

}
