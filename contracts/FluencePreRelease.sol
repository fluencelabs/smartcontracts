pragma solidity ^0.4.18;


import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


interface Certifier {
    function certified(address _who) constant returns (bool);
}


contract FluencePreRelease is Ownable {
    event Released(address indexed caller, address indexed _to, uint256 amount);

    using SafeMath for uint256;

    mapping (address => uint256) public released;

    address public certifier;

    address public preSale;

    address public token;

    bool public launched;

    address public spender;

    modifier beforeLaunch {
        require(!launched);
        _;
    }

    modifier afterLaunch {
        require(launched);
        _;
    }

    function FluencePreRelease(address _certifier, address _preSale, address _token, address _spender) {
        require(_certifier != address(0x0));
        require(_preSale != address(0x0));
        require(_token != address(0x0));

        certifier = _certifier;
        preSale = _preSale;
        token = _token;

        if (_spender == address(0x0)) {
            spender = msg.sender;
        }
        else {
            spender = _spender;
        }
    }

    // Can preset only before releasing is launched
    function presetReleased(address _to, uint256 amount) onlyOwner beforeLaunch public {
        released[_to] = amount;
    }

    // After launch, owner can't do anything with the contract
    function launch() onlyOwner beforeLaunch public {
        launched = true;
    }

    function release(address _holder) public afterLaunch returns (uint256 amount) {
        address beneficiary = _holder;
        if (beneficiary == address(0x0)) beneficiary = msg.sender;
        // check if verified
        require(Certifier(certifier).certified(beneficiary));

        address source = msg.sender;
        // check fpt balance
        // subtract $released
        amount = ERC20Basic(preSale).balanceOf(source).sub(released[source]);
        require(amount > 0);

        // release tokens
        released[source] = released[source].add(amount);
        assert(released[source] == ERC20Basic(preSale).balanceOf(source));

        assert(StandardToken(token).transferFrom(spender, beneficiary, amount));
        Released(source, beneficiary, amount);
    }

    function bytesToAddress(bytes _address) internal returns (address) {
        uint160 m = 0;
        uint160 b = 0;

        for (uint8 i = 0; i < 20; i++) {
            m *= 256;
            b = uint160(_address[i]);
            m += (b);
        }

        return address(m);
    }

    function() public {
        if (msg.data.length == 20) {
            release(bytesToAddress(msg.data));
        }
        else {
            release(msg.sender);
        }
    }

}