pragma solidity ^0.5.16;

contract SmartLegalContract
{
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, AWAITING_CHECK, COMPLETE }

    address payable public seller;
    address public buyer;
    address public portAccount;
    address public companySRLAccount;
    uint public amount;
    State public currentState;

    //only buyer can access
    modifier isBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
    //only Port can access
    modifier isPort() {
        require(msg.sender == portAccount);
        _;
    }
    
    //only GammaSRL can access.
    modifier isCompanySRL() {
        require(msg.sender == companySRLAccount);
        _;
    }

    function getState() public view returns(State) {
        return currentState;
    }

    constructor(
        address payable _seller, address _buyer,
        address _portAccount, address _companySRLAccount,
        uint _amount)
        public
    {
        seller = _seller;
        buyer = _buyer;
        portAccount = _portAccount;
        companySRLAccount = _companySRLAccount;
        amount = _amount;
        currentState = State.AWAITING_PAYMENT;
    }

    function buyerDeposit() public payable isBuyer {
        require(currentState == State.AWAITING_PAYMENT);
        require(msg.value == amount);
        currentState = State.AWAITING_DELIVERY;
    }

    function deliveryDone() public isPort {
        require(currentState == State.AWAITING_DELIVERY);
        currentState = State.AWAITING_CHECK;
    }

    function checkDone() public isCompanySRL {
        require(currentState == State.AWAITING_CHECK);
        seller.transfer(address(this).balance);
        currentState = State.COMPLETE;
    }
}
