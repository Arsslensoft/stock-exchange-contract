pragma solidity ^0.5.0;
contract StockExchange {
    // The asset structure
    struct Asset {
        bytes6 id;  // 6 bytes string
        int8 price;
        int8 quantity;
    }
    // The transaction structure
    struct Transaction {
        bytes6 source; // 6 bytes string
        bytes6 target; // 6 bytes string
        int8 quantity;
        int8 price;
        uint256 timestamp;
        int8 state; // 0:PENDING / 1:VALIDATED / 2:REJECTED
    }
    // Counts
    int transaction_count;
    int asset_count;

    // Lists
    mapping (int => Transaction) transactions;
    mapping (int => Asset) assets;

    // private functions
    // compare 6 bytes string
    function stringsEqual(bytes6 a, bytes6 b) internal pure returns (bool) {
        // @todo unroll this loop
        for (uint i = 0; i < 6; i ++) {
            if (a[i] != b[i]) {
                return false;
            }
        }
        return true;
    }
    // Events
    event AssetJoined(address indexed asset_address, int index, bytes6 id, int8 quantity, int8 price, uint256 timestamp);
    event TransactionExecuted(address indexed source_address, int source_asset_index, int target_asset_index, bytes6 source, 
    bytes6 target, int8 quantity, int8 price, uint256 timestamp, int8 state);
    event AssetUpdated(address indexed asset_address, int index, bytes6 id, int8 quantity, int8 price, uint256 timestamp);

    // Gets an asset index in the mapping by id
    function getAssetIndex(bytes6 _id) public view returns (int index) {
        for (int i = 1; i <= asset_count; i++) {
            if(stringsEqual(assets[i].id, _id) == true)
                return i;
        } 
        return -1;
    }
    

    // Gets assets count
    function getAssetsCount() public view  returns (int uid) {
        return asset_count;
    }
    // Gets transactions count
    function getTransactionsCount() public view  returns (int uid) {
        return transaction_count;
    }  

    // Registers an asset into the assets list
    function register(bytes6 _id, int8 _quantity, int8 _price) public payable returns (bool success) {
        int asset_index = getAssetIndex(_id);
        if(asset_index == -1){
            asset_count = asset_count + 1;
            Asset memory _asset = Asset(_id, _price, _quantity); 
            assets[asset_count] = _asset;
            emit AssetJoined(msg.sender,asset_count,  _id, _quantity, _price, now);
        } else {
            assets[asset_index].quantity = _quantity; 
            assets[asset_index].price = _price;
            emit AssetUpdated(msg.sender, asset_index, _id, _quantity, _price, now);
        }

        return true;
    }
    // Gets an asset by index in the list
    function getAssetByIndex(int i) public view returns (bytes6 id, int8 price, int8 quantity) {
        if(i >= 1 && i <= asset_count)
            return (assets[i].id, assets[i].price, assets[i].quantity);
        else
            return ("NONEAA",-1,-1);
    }
    // Gets an asset by id (string)
    function getAsset(bytes6 _id) public view returns (bytes6 id, int8 price, int8 quantity) {
        for (int i = 1; i <= asset_count; i++) {
            if(stringsEqual(assets[i].id, _id) == true)
                return (assets[i].id, assets[i].price, assets[i].quantity);
        } 
        return ("NONEAA",-1,-1);
    }
    // executes a transaction where source buys from target a certain quantity
    function transact(bytes6 source, bytes6 target, int8 quantity)  public payable returns (bool success) {
        int si = getAssetIndex(source);
        int ti = getAssetIndex(target);
        if(si == -1 || ti == -1) {
            return false;
        }
        else {
            transaction_count = transaction_count + 1;
            Transaction memory _t = Transaction(assets[si].id, assets[ti].id, quantity, assets[ti].price, now, 0); 
            transactions[transaction_count] = _t;

            if((assets[ti].quantity - quantity) >= 0) { // validate transaction
                assets[ti].quantity -= quantity;
                transactions[transaction_count].state = 1;
                emit TransactionExecuted(msg.sender,si,ti, transactions[transaction_count].source, transactions[transaction_count].target, transactions[transaction_count].quantity, transactions[transaction_count].price, transactions[transaction_count].timestamp, transactions[transaction_count].state);
            }
            else if(assets[ti].quantity > 0) { // validate partial transaction 
                transactions[transaction_count].state = 1;
                transactions[transaction_count].quantity = assets[ti].quantity;
                emit TransactionExecuted(msg.sender, si, ti, transactions[transaction_count].source, transactions[transaction_count].target, transactions[transaction_count].quantity, transactions[transaction_count].price, transactions[transaction_count].timestamp, transactions[transaction_count].state);

                // create the rejected transaction
                transaction_count = transaction_count + 1;
                Transaction memory _t1 = Transaction(assets[si].id, assets[ti].id, quantity - assets[ti].quantity, assets[ti].price, now, 0); 
                transactions[transaction_count] = _t1;
                assets[ti].quantity = 0;
                transactions[transaction_count].state = 2;
                emit TransactionExecuted(msg.sender, si, ti, transactions[transaction_count].source, transactions[transaction_count].target, transactions[transaction_count].quantity, transactions[transaction_count].price, transactions[transaction_count].timestamp, transactions[transaction_count].state);
            }
            else {
                transactions[transaction_count].state = 2;
                emit TransactionExecuted(msg.sender, si, ti, transactions[transaction_count].source, transactions[transaction_count].target, transactions[transaction_count].quantity, transactions[transaction_count].price, transactions[transaction_count].timestamp, transactions[transaction_count].state);
            }
        }
        return true;   
    }
    // Get transaction by index
    function getTransactionByIndex(int i) public view 
        returns (bytes6 source, bytes6 target, int8 quantity, int8 price, uint256 timestamp, int8 state ) {
        if(i >= 1 && i <= transaction_count)
            return (transactions[i].source, transactions[i].target, 
                transactions[i].quantity, transactions[i].price, transactions[i].timestamp, transactions[i].state);
        else
            return ("NONEAA", "NONEAA",-1,-1, 0, 2);
    }    
    
    // Get the next transaction index involving an asset
    function getNextTransactionIdInvolvingAsset(bytes6 id, int start) public view  returns (int) {
        if(start < 1 || start > transaction_count)
            return -1;
            
        for (int i = start; i <= transaction_count; i++) {
            if(stringsEqual(transactions[i].source, id) == true || stringsEqual(transactions[i].target, id))
                return i;
        }
        return -1;
    }
}