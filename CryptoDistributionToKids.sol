// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract CryptoDistributionToKids{
    address owner;

    event LogKidFundingReceived(address addr, uint amount, uint contractBal);
    
    constructor(){
        owner = msg.sender;
    }

    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can add kids");
        _;
    }

    // add KID to contract
    Kid[] public kids;

    function addKid(address payable _walletAddress, string memory _firstName, string memory _lastName, uint _releaseTime, uint _amount) public onlyOwner {
        kids.push(Kid(
            _walletAddress,
            _firstName,
            _lastName,
            _releaseTime,
            _amount,
            false
        ));
    }

    function balanceOf() public view returns(uint){
        return address(this).balance;
    }

    // deposit funds to contract, specifically to a kid's account
    function deposit(address _walletAddress) payable public{
        addToKidsBalance(_walletAddress);
    }

    function addToKidsBalance(address _walletAddress) private {
        for(uint i=0; i<kids.length; i++){
            if(kids[i].walletAddress == _walletAddress){
                kids[i].amount += msg.value;
                emit LogKidFundingReceived(_walletAddress, msg.value, balanceOf());
            }
        }
    }

    function getIndex(address _walletAddress) view private returns(uint){
        for(uint i=0; i<kids.length; i++){
            if(kids[i].walletAddress == _walletAddress){
                return i;
            }
        }
        return 9999999999;
    }

    // kid checks if amount can be withdrawn
    function availableToWithdraw(address _walletAddress) public returns(bool){
        uint i = getIndex(_walletAddress);
        require(block.timestamp > kids[i].releaseTime, "Cannot withdraw at this time");
        if(block.timestamp > kids[i].releaseTime){
            kids[i].canWithdraw = true;
            return true;
        }
        else{
            return false;
        }
    }

    // withdraw money
    function withdraw(address payable _walletAddress) payable public{
        uint i = getIndex(_walletAddress);
        require(msg.sender == kids[i].walletAddress, "Not the same kid");
        require(kids[i].canWithdraw == true, "Cannot withdraw yet");
        kids[i].walletAddress.transfer(kids[i].amount);
    }
}