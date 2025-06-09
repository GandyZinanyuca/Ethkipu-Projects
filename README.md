# 🧾 SubastaFinalizaConReembolsos - Smart Contract

This smart contract implements an **English-style auction** with automatic refunds to outbid participants, time extensions for last-minute bids, and a fee mechanism for the auctioneer.

## 📜 License

This project is licensed under [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.html).

---

## ⚙️ General Functionality

This contract allows:
- Participants to place bids if they outbid the current highest.
- Outbid participants to retrieve their funds at any time before the auction ends.
- The auctioneer to finalize the auction and:
  - Receive the winning bid amount.
  - Refund losing participants minus a small fee (2%).
  - Collect the accumulated fee earnings.

---

## 🔧 Public Functions

### `constructor()`
Initializes the contract:
- Sets the `auctioneer` (contract deployer),
- Defines a base bid (`2 ether`),
- Sets auction duration to 2 days.

---

### `ofertar() external payable`
Allows users to place a bid:
- Requires auction to be active.
- New bid must exceed current highest bid by at least 5%.
- If the bidder was previously the highest bidder, they get refunded their previous amount.
- If it's a last-minute bid (within 10 minutes of the end), the auction is extended by 10 minutes.

---

### `retornarDinero() external`
Allows users to manually withdraw refunds during the auction:
- Only for users who were outbid.
- Transfers the saved refund amount.
- Not allowed for the current highest bidder.

---

### `finalizarSubasta() external`
Finalizes the auction (after the end time):
- Marks the auction as completed.
- Transfers the highest bid to the auctioneer.
- Refunds other bidders minus a 2% fee.
- Transfers accumulated fees to the auctioneer.

---

## 🧮 Public Variables

| Name | Type | Description |
|------|------|-------------|
| `subastador` | `address` | The auctioneer / owner. |
| `ofertaBase` | `uint` | Base bid required to start bidding (2 ETH). |
| `ofertaMaxima` | `uint` | Highest bid placed so far. |
| `mejorPostor` | `address` | Address of the current top bidder. |
| `finalizada` | `bool` | Whether the auction has ended. |
| `inicio` | `uint` | Start timestamp. |
| `fin` | `uint` | End timestamp. |
| `acumuladoPorSubastador` | `uint` | Accumulated fee earnings for the auctioneer. |
| `devoluciones` | `mapping(address => uint)` | Refundable amounts for each bidder. |
| `postores` | `address[]` | List of bidders. |

---

## 📢 Events

| Event | Parameters | Description |
|-------|------------|-------------|
| `NuevaOferta` | `address bidder, uint amount, uint newEndTime` | Emitted when a new valid bid is placed. |
| `SubastaFinalizada` | `address winner, uint amount, uint totalFees` | Emitted after auction is finalized. |
| `ReembolsoAutomatico` | `address bidder, uint refunded, uint feeCharged` | Indicates an automatic refund with fee deduction. |
| `DineroRegresa` | `address bidder, uint refunded` | Emitted when a user manually withdraws a refund. |

---

## 🔒 Security & Validations

- No bids accepted outside the auction window.
- Auction can't be finalized prematurely.
- Refunds are zeroed before sending Ether (to prevent reentrancy).
- Only valid bid increments (5% minimum) are allowed.

---

## ✅ Requirements to Run

- Solidity ^0.8.2.
- Ethereum-compatible test network (e.g., Sepolia).
- Recommended tools: [Remix IDE](https://remix.ethereum.org), Hardhat, or Foundry.

---

## ✍️ Author
Developed by [Your Name or Alias]  
Project for learning smart contracts, auctions, and safe Ether handling.
