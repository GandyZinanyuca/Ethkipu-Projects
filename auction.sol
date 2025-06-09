// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract AuctionWithRefundsAndFinalization {
    address public auctioneer;
    uint public baseBid;
    uint public highestBid;
    address public highestBidder;
    bool public ended;

    uint public start;
    uint public end;
    uint constant TIME_EXTENSION = 10 minutes;
    uint constant MIN_INCREMENT_PERCENT = 5;
    uint constant FEE_PERCENT = 2;

    uint public accumulatedFees;

    mapping(address => uint) public refunds;
    mapping(address => bool) private hasBid;
    address[] public bidders;

    event NewBid(address indexed bidder, uint amount, uint newEnd);
    event AuctionEnded(address winner, uint amount, uint totalFees);
    event AutoRefund(address indexed bidder, uint refunded, uint feeTaken);
    event ManualRefund(address indexed bidder, uint refunded);

    constructor() {
        auctioneer = msg.sender;
        baseBid = 2 ether;
        start = block.timestamp;
        end = block.timestamp + 2 days;
    }

    function placeBid() external payable {
        require(block.timestamp >= start, "The auction has not started yet");
        require(block.timestamp <= end, "The auction has ended");
        require(!ended, "The auction has already ended");

        if (highestBid == 0) {
            require(msg.value >= baseBid, "The bid is lower than the minimum base (2 ETH)");
        } else {
            uint minIncrement = (highestBid * (100 + MIN_INCREMENT_PERCENT)) / 100;
            require(msg.value >= minIncrement, "You must exceed the current bid by at least 5%");
        }

        if (msg.sender == highestBidder) {
            refunds[msg.sender] += highestBid;
        } else if (highestBid > 0) {
            refunds[highestBidder] += highestBid;
        }

        if (!hasBid[msg.sender]) {
            bidders.push(msg.sender);
            hasBid[msg.sender] = true;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        if (end - block.timestamp <= 10 minutes) {
            end = block.timestamp + TIME_EXTENSION;
        }

        emit NewBid(msg.sender, msg.value, end);
    }

    function withdrawRefund() external payable {
        require(block.timestamp >= start, "The auction has not started yet");
        require(block.timestamp <= end, "The auction has ended");
        require(!ended, "The auction has already ended");

        require(refunds[msg.sender] != 0, "You haven't placed a bid");
        uint amount = refunds[msg.sender];
        require(amount > 0, "You have no funds to withdraw");
        require(amount >= highestBid, "Your refund is lower than the current highest bid");

        if (refunds[msg.sender] != 0) {
            payable(msg.sender).transfer(refunds[msg.sender]);
            refunds[msg.sender] = 0;
        }

        emit ManualRefund(msg.sender, amount);
    }

    function endAuction() external {
        require(block.timestamp >= end, "The auction has not yet ended");
        require(!ended, "The auction has already ended");

        ended = true;

        // Transfer the winning bid to the auctioneer
        if (highestBid > 0) {
            payable(auctioneer).transfer(highestBid);
        }

        // Refund all bidders except the winner
        for (uint i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            if (bidder != highestBidder) {
                uint amount = refunds[bidder];
                if (amount > 0) {
                    uint fee = (amount * FEE_PERCENT) / 100;
                    uint refundAmount = amount - fee;

                    accumulatedFees += fee;
                    refunds[bidder] = 0;

                    payable(bidder).transfer(refundAmount);
                    emit AutoRefund(bidder, refundAmount, fee);
                }
            }
        }

        // Transfer fees to auctioneer
        if (accumulatedFees > 0) {
            payable(auctioneer).transfer(accumulatedFees);
            accumulatedFees = 0;
        }

        emit AuctionEnded(highestBidder, highestBid, accumulatedFees);
    }
}
