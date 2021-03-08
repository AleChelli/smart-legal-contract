pragma solidity ^0.5.16;

contract SmartLegalContract
{
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, AWAITING_CHECK, COMPLETE }

    address payable public seller;
    address public buyer;
    address public genovaPortAccount;
    address public gammaSRLAccount;
    uint public amount;
    State public currentState;

    //only buyer can access
    modifier isBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
    //only GenovaPort can access
    modifier isGenovaPort() {
        require(msg.sender == genovaPortAccount);
        _;
    }
    
    //only GammaSRL can access.
    modifier isGammaSRL() {
        require(msg.sender == gammaSRLAccount);
        _;
    }

    function getState() public view returns(State) {
        return currentState;
    }

    constructor(
        address payable _seller, address _buyer,
        address _genovaPortAccount, address _gammaSRLAccount,
        uint _amount)
        public
    {
        seller = _seller;
        buyer = _buyer;
        genovaPort = _genovaPortAccount;
        gammaSRL = _gammaSRLAccount;
        amount = _amount;
        currentState = State.AWAITING_PAYMENT;
    }

    function buyerDeposit() public payable isBuyer {
        require(currentState == State.AWAITING_PAYMENT);
        require(msg.value == amount);
        currentState = State.AWAITING_DELIVERY;
    }

    function deliveryDone() public isGenovaPort {
        require(currentState == State.AWAITING_DELIVERY);
        currentState = State.AWAITING_CHECK;
    }

    function checkDone() public isGammaSRL {
        require(currentState == State.AWAITING_CHECK);
        seller.transfer(address(this).balance);
        currentState = State.COMPLETE;
    }
}
