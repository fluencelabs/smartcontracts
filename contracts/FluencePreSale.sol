pragma solidity ^0.4.13;


/**
 * Math operations with safety checks
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }

}


/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}


/*
 * Haltable
 *
 * Abstract contract that allows children to implement an
 * emergency stop mechanism. Differs from Pausable by causing a throw when in halt mode.
 *
 *
 * Originally envisioned in FirstBlood ICO contract.
 */
contract Haltable is Ownable {
    bool public halted;

    modifier stopInEmergency {
        require(!halted);
        _;
    }

    modifier onlyInEmergency {
        require(halted);
        _;
    }

    // called by the owner on emergency, triggers stopped state
    function halt() external onlyOwner {
        halted = true;
    }

    // called by the owner on end of emergency, returns to normal state
    function unhalt() external onlyOwner onlyInEmergency {
        halted = false;
    }

}


contract FluencePreSale is Haltable {
    using SafeMath for uint;
    using SafeMath for uint256;

    mapping (address => uint256) public balanceOf;

    /*/
     *  Constants
    /*/

    string public constant name = "Fluence Presale Token";

    string public constant symbol = "FPT";

    uint   public constant decimals = 18;

    // 6% of tokens
    uint256 public constant SUPPLY_LIMIT = 6000000;

    // What is given to contributors, <= SUPPLY_LIMIT
    uint256 public totalSupply;

    // If soft cap is not reached, refund process is started
    uint256 public softCap = 1000 ether;

    // Basic price
    uint256 public constant basicThreshold = 500 finney;
    uint public constant basicTokensPerEth = 1500;

    // Advanced price
    uint256 public constant advancedThreshold = 5 ether;
    uint public constant advancedTokensPerEth = 2250;

    // Expert price
    uint256 public constant expertThreshold = 100 ether;
    uint public constant expertTokensPerEth = 3000;

    // As we have different prices for different amounts,
    // we keep a mapping of contributions to make refund
    mapping (address => uint256) public etherContributions;

    // Max balance of the contract
    uint256 public etherCollected;

    // Address to withdraw ether to
    address public beneficiary;

    uint public startAtBlock;

    uint public endAtBlock;

    event GoalReached(uint amountRaised);

    event SoftCapReached(uint softCap);

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);

    event Refunded(address indexed holder, uint256 amount);

    // If soft cap is reached, withdraw should be available
    modifier softCapReached {
        require(etherCollected >= softCap);
        _;
    }

    modifier duringPresale {
        require(block.number >= startAtBlock && block.number <= endAtBlock && totalSupply < SUPPLY_LIMIT);
        _;
    }

    modifier duringRefund {
        require(block.number > endAtBlock && etherCollected < softCap && this.balance > 0);
        _;
    }

    function FluencePreSale(uint _startAtBlock, uint _endAtBlock){
        require(_startAtBlock > 0 && _endAtBlock > 0);
        beneficiary = msg.sender;
        startAtBlock = _startAtBlock;
        endAtBlock = _endAtBlock;
    }

    function setBeneficiary(address to) onlyOwner external {
        require(to != 0x0);
        beneficiary = to;
    }

    function withdraw() onlyOwner softCapReached external {
        require(this.balance > 0);
        beneficiary.transfer(this.balance);
    }

    function contribute(address _address) private stopInEmergency duringPresale {
        require(msg.value >= basicThreshold || owner == _address); // Minimal contribution

        uint256 tokensToIssue;

        if(msg.value >= expertThreshold) {
            tokensToIssue = (msg.value / 1 ether).mul(expertTokensPerEth);
        } else if(msg.value >= advancedThreshold) {
            tokensToIssue = (msg.value / 1 ether).mul(advancedTokensPerEth);
        } else {
            tokensToIssue = (msg.value / 1 ether).mul(basicTokensPerEth);
        }

        totalSupply = totalSupply.add(tokensToIssue);
        require(totalSupply <= SUPPLY_LIMIT);

        etherContributions[_address] = etherContributions[_address].add(msg.value);
        uint collectedBefore = etherCollected;
        etherCollected = etherCollected.add(msg.value);
        balanceOf[_address] = balanceOf[_address].add(tokensToIssue);

        NewContribution(_address, tokensToIssue, msg.value);

        if(totalSupply == SUPPLY_LIMIT) {
            GoalReached(etherCollected);
        }
        if(etherCollected >= softCap && collectedBefore < softCap) {
            SoftCapReached(etherCollected);
        }
    }

    function() external payable {
        contribute(msg.sender);
    }

    function refund() stopInEmergency duringRefund external {
        uint tokensToBurn = balanceOf[msg.sender];

        require(tokensToBurn > 0); // Sender must have tokens
        balanceOf[msg.sender] = 0; // Burn

        uint amount = etherContributions[msg.sender]; // User contribution amount

        require(amount > 0); // Amount must be positive -- refund is not processed yet

        etherContributions[msg.sender] = 0; // Clear state

        // Reduce counters
        etherCollected = etherCollected.sub(amount);
        totalSupply = totalSupply.sub(balanceOf[msg.sender]);

        msg.sender.transfer(amount); // Process refund. In case of error, it will be thrown

        Refunded(msg.sender, amount);
    }


}
