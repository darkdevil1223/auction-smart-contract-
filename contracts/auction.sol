// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract auction{
    address payable public auctioner;
    uint public stblock;
    uint public etblock;

    enum auc_state{Started, Running, Ended, Canceled}
    auc_state public auctionstate;

    // uint public highestbid;
    uint public highestpayablebid;
    uint public bidinc;

    address payable public highestbidder;
    
    mapping(address => uint) public bids;

    constructor(){
        auctioner = payable(msg.sender);
        auctionstate =  auc_state.Running;
        stblock = block.number;
        etblock = stblock + 240;
        bidinc = 1 ether;

    }

    modifier notowner(){
        require(msg.sender != auctioner,"owner cannot bid");
        _;

    }
    
    modifier owner(){
        require(msg.sender == auctioner,"owner cannot bid");
        _;

    }

    modifier Started(){
        require(block.number>stblock);
        _;

    }

    modifier beforeending(){
        require(block.number<etblock);
        _;

    }
    
    
    function min(uint a, uint b) pure public returns(uint){
        if(a<=b)
        return a;
        else 
        return b;

    }

    function cancleAuc() public owner{
        auctionstate = auc_state.Canceled;

    }
    function endAuc() public owner{
        auctionstate = auc_state.Ended;

    }


    function bid()payable public notowner Started beforeending{
        
        require(auctionstate == auc_state.Running);
        require(msg.value>=1 ether);
        
        uint currentbid = bids[msg.sender] + msg.value; 
        require(currentbid>highestpayablebid);

        bids[msg.sender] = currentbid;

        if(currentbid<bids[highestbidder]){
            highestpayablebid = min(currentbid + bidinc, bids[highestbidder]);
        } 
         else{
              highestpayablebid = min(currentbid, bids[highestbidder]+ bidinc);
              highestbidder = payable(msg.sender);
         }

        


    }

    function finilize() public{
        require(auctionstate == auc_state.Canceled|| auctionstate == auc_state.Ended || block.number>etblock);
        require(msg.sender == auctioner || bids[msg.sender]>0);

        address payable person;
        uint value;
         if(auctionstate == auc_state.Canceled){
             person = payable(msg.sender);
             value = bids[msg.sender];


         }
         else{
             if(msg.sender == auctioner){
                 person = auctioner;
                 value = highestpayablebid;

             }
             else{
                 if(msg.sender == highestbidder){
                     person = highestbidder;
                     value = bids[highestbidder]-highestpayablebid;


                 }
                 else{
                     person = payable(msg.sender);
                     value = bids[msg.sender];
                 }
             }
             
         }
         bids[msg.sender]=0;
         person.transfer(value);
    }


}