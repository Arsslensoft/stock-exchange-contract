pragma solidity ^0.5.0;
contract StockExchange {
    
    struct Asset {
        bytes6 id; 
        int8 price;
        int8 quantity;
    }
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

    mapping (int => Transaction) transactions;
    mapping (int => Asset) assets;

    // private functions
    function stringsEqual(bytes6 a, bytes6 b) internal pure returns (bool) {
        // @todo unroll this loop
        for (uint i = 0; i < 6; i ++) {
            if (a[i] != b[i]) {
                return false;
            }
        }
        return true;
    }
    function getAssetIndex(bytes6 _id) public view returns (int index) {
        for (int i = 1; i <= asset_count; i++) {
            if(stringsEqual(assets[i].id, _id) == true)
                return i;
        } 
        return -1;
    }
    


    function getAssetsCount() public view  returns (int uid) {
        return asset_count;
    }

    function getTransactionsCount() public view  returns (int uid) {
        return transaction_count;
    }  
    function register(bytes6 _id, int8 _quantity, int8 _price) public payable returns (bool success) {
        asset_count = asset_count + 1;
        Asset memory _asset = Asset(_id, _price, _quantity); 
        assets[asset_count] = _asset;
        return true;
    }
    function getAssetByIndex(int i) public view returns (bytes6 id, int8 price, int8 quantity) {
        return (assets[i].id, assets[i].price, assets[i].quantity);
    }
    function getAsset(bytes6 _id) public view returns (bytes6 id, int8 price, int8 quantity) {
        for (int i = 1; i <= asset_count; i++) {
            if(stringsEqual(assets[i].id, _id) == true)
                return (assets[i].id, assets[i].price, assets[i].quantity);
        } 
        return ("NONEAA",10,100);
    }
    // source buys from target
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
            }
            else if(assets[ti].quantity > 0) { // validate partial transaction 
                transactions[transaction_count].state = 1;
                transactions[transaction_count].quantity = assets[ti].quantity;
                // create the rejected transaction
                transaction_count = transaction_count + 1;
                Transaction memory _t1 = Transaction(assets[si].id, assets[ti].id, quantity - assets[ti].quantity, assets[ti].price, now, 0); 
                transactions[transaction_count] = _t1;
                assets[ti].quantity = 0;
                transactions[transaction_count].state = 2;
            }
            else {
                transactions[transaction_count].state = 2;
            }
        }
        return true;   
    }
    
    function getTransaction(int i) public view 
        returns (bytes6 source, bytes6 target, int8 quantity, int8 price, uint256 timestamp, int8 state ) {
        return (transactions[i].source, transactions[i].target, 
            transactions[i].quantity, transactions[i].price, transactions[i].timestamp, transactions[i].state);
    }    
    function getNextTransactionIdInvolvingAsset(bytes6 id, int start) public view  returns (int) {
        for (int i = start; i <= transaction_count; i++) {
            if(stringsEqual(transactions[i].source, id) == true || stringsEqual(transactions[i].target, id))
                return i;
        }
        return -1;
    }
}