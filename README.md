# AuctionWithRefundsAndFinalization - Smart Contract

This smart contract implements an **English-style auction** with:

* Refunds to outbid participants.
* Time extension for last-minute bids.
* Fee mechanism that rewards the auctioneer.

##  License

This project is licensed under [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.html).

---

## General Functionality

This contract allows:

* Users to place bids above a base price and previous bids.
* Automatically handles refunds for outbid participants.
* Allows users to manually withdraw refunds during the auction.
* Auctioneer can end the auction after expiration.
* Fee (2%) is deducted from refunds and sent to the auctioneer.

---

## Public Functions

### `constructor()`

Initializes the auction:

* Sets the auctioneer as the contract deployer.
* Sets a base bid of 2 ETH.
* Auction duration is 2 days from deployment.

### `placeBid() external payable`

Allows a participant to bid:

* Auction must be active.
* Bid must exceed the current highest bid by at least 5%.
* Automatically refunds the previous highest bidder.
* Extends the auction time by 10 minutes if close to the end.

### `withdrawRefund() external payable`

Allows participants to manually withdraw their refundable amount:

* Must not be the current highest bidder.
* Only possible if a refund is available.
* Funds are sent and internal balance is cleared.

### `endAuction() external`

Ends the auction after time has expired:

* Transfers the highest bid to the auctioneer.
* Refunds other bidders minus a 2% fee.
* Transfers collected fees to the auctioneer.

---

##  Public Variables

| Variable                | Type        | Description                                 |
| ----------------------- | ----------- | ------------------------------------------- |
| `auctioneer`            | `address`   | Address of the auctioneer (contract owner). |
| `baseBid`               | `uint`      | Minimum bid (2 ETH).                        |
| `highestBid`            | `uint`      | Current highest bid.                        |
| `highestBidder`         | `address`   | Address of the current top bidder.          |
| `ended`                 | `bool`      | True if auction is finalized.               |
| `start`                 | `uint`      | Auction start timestamp.                    |
| `end`                   | `uint`      | Auction end timestamp.                      |
| `TIME_EXTENSION`        | `uint`      | 10 minutes extension when near deadline.    |
| `MIN_INCREMENT_PERCENT` | `uint`      | Minimum 5% increase for valid bids.         |
| `FEE_PERCENT`           | `uint`      | Fee percentage (2%) for refunds.            |
| `accumulatedFees`       | `uint`      | Total fees collected for the auctioneer.    |
| `refunds`               | `mapping`   | Amounts available for refund per bidder.    |
| `bidders`               | `address[]` | List of all bidders.                        |

---

##  Events

| Event          | Parameters                                     | Description                                             |
| -------------- | ---------------------------------------------- | ------------------------------------------------------- |
| `NewBid`       | `address bidder, uint amount, uint newEnd`     | Emitted when a valid new bid is placed.                 |
| `AuctionEnded` | `address winner, uint amount, uint totalFees`  | Emitted when the auction ends successfully.             |
| `AutoRefund`   | `address bidder, uint refunded, uint feeTaken` | Emitted when outbid participants are refunded with fee. |
| `ManualRefund` | `address bidder, uint refunded`                | Emitted when a user manually withdraws a refund.        |

---

## Security Notes

* Bids must be at least 5% higher than the current top bid.
* Prevents premature finalization.
* Refunds zeroed before transfer to prevent reentrancy.
* Fees incentivize the auctioneer to manage the auction properly.

---

## 🚀 Deployment & Testing

* Compiler: Solidity >=0.8.2 <0.9.0;
* Recommended network: Sepolia testnet
* Tools: Remix 
