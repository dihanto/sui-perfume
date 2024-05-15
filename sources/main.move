module dacade::sui_perfume{

    use std::string::String;
    use sui::balance::Balance;
    use sui::sui::SUI;

    const ErrorInvalid: u64 = 1;
    const ErrorNotStoreOwner: u64 = 2;

    public struct Store has key{
        id: UID,
        store_owner_cap: ID,
        balance: Balance<SUI>,
        owner_address: address,
        items: vector<Perfume>,
        item_count: u64,
    }

    public struct StoreOwnerCapability has key{
        id: UID,
        store: ID,
    }

    public struct Perfume has store{
        id: u64,
        name: String,
        size: u64,
        price: u64,
        stock: u64,
    }

    public struct PurchasedPerfume has key{
        id: UID,
        store_id: ID,
        perfume_id: u64,
    }

    public struct StoreCreated has copy, drop{
        store_id: ID,
        store_owner_cap: ID,
    }

    public struct PerfumeAdded has copy, drop{
        store_id: ID,
        perfume_id: u64,
    }

    public struct PerfumePurchased has copy, drop{
        store_id: ID,
        perfume_id: u64,
        buyer: address,
    }

    public struct StoreWithdrawal has copy, drop{
        store_id: ID,
        amount: u64,
        recipient: address,
    }
}