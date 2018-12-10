Stock Exchange Solidity Contract
====

# Introduction
This project was created in order to implement a simple private stock exchange blockchain ledger based on ethereum.

# Requirements
You need to have a solidity editor/compiler

For Example:

- Visual Studio Code
- Visual Studio Code Solidity Plugin/Compiler

# Creating the contract
First I will start by creating the contract

## Base structure
Our contract will use solidity 0.5.0 compiler and it will be named StockExchange.

```solidity
pragma solidity ^0.5.0;
contract StockExchange {

}
```

## Adding the Asset
I will now add the asset
```solidity
pragma solidity ^0.5.0;
contract StockExchange {
   struct Asset {
        bytes6 id; 
        int8 price;
        int8 quantity;
    }
}
```
The asset is the company identified by a 6 bytes string **(id)**, that have a certain number of stocks **(quantity)** that is willing to sell it at a certain price **(price)**.

## Adding the transaction
I will now add the transaction

```solidity
pragma solidity ^0.5.0;
contract StockExchange {
    struct Transaction {
        bytes6 source;
        bytes6 target;
        int8 quantity;
        int8 price;
        uint256 timestamp;
        int8 state; // 0:PENDING / 1:VALIDATED / 2:REJECTED
    }
}
```

The principle is simple:
- A transaction needs to be from source to target (the **source** buys from the **target**).
- A buyer will buy a certain quantity of stocks.
- A stock price is the same as the targets **price**.
- The **timestamp** is the time of transaction execution or **now**/ **block.timestamp**.
- The state can be:
  - Pending: when the transaction has been created.
  - Validated: when the transaction is valid, this means that the target quantity is credited and the transaction has been executed.
  - Rejected: in this case, the desired quantity is not available

**Note**: A partial transaction is split on 2 (Completed and Rejected)

**Example**:
Let's say I have 2 assets ``("ARSLEN", 1,3)`` and ``("TUNAIR", 1, 4)``

I have this transaction coming from **ARSLEN** to **TUNAIR** ``("ARSLEN", "TUNAIR", 5)``.

I know that **ARSLEN** can buy only 4 from TUNAIR, because it has only 4 available stocks.

So the resulting transactions will be **2** assuming there is **n** previous transactions executed by the system.

- **Transaction n+1**: A validated transaction ``("ARSLEN", "TUNAIR", 4, 1, timestamp_of_tn+1, 1)``
- **Transaction n+2**: A rejected transaction ``("ARSLEN", "TUNAIR", 1, 1, timestamp_of_tn+2, 0)``

## Adding the mappings
Now I will add the mappings
```solidity
pragma solidity ^0.5.0;
contract StockExchange {
    struct Transaction {
        bytes6 source;
        bytes6 target;
        int8 quantity;
        int8 price;
        uint256 timestamp;
        int8 state; // 0:PENDING / 1:VALIDATED / 2:REJECTED
    }
    int transaction_count;
    int asset_count;
    // transactions list
    mapping (int => Transaction) transactions;
    // assets list
    mapping (int => Asset) assets;
}
```
**Warning**: The lists starts from index **1** and ends at **transaction_count** or **asset_count** depending on the desired list.

## Adding the payable functions
Well I have 2 payable functions because they change the state of the contract:

- **register**: registers an asset
- **transact**: executes a transaction

**Note**: the functions need to be paid in gas as transaction in ethereum, otherwise they will not be executed.

## Adding the other functions
I will now describe briefly the functions

- stringsEqual: a private function to compare strings.
- getAssetIndex: a function that returns the **index** of the asset by a given **id (bytes6)**, 1 <= **index** <= assets_count.
- getAssetsCount: returns the number of available assets.
- getTransactionsCount: returns the number of transactions.
- getAssetByIndex: returns an Asset by a given **index**.
- getAsset: returns an Asset by a given **id**.
- getTransaction: returns a transaction by a given **id**.
- getNextTransactionIdInvolvingAsset: returns a transaction index by a given **id** and a **start** position.

# Credits
Goes to me, the moon :p


