module dacade::sui_perfume{

    use std::string::String;
    use sui::balance;
    use sui::balance::Balance;
    use sui::coin;
    use sui::sui::SUI;

    const ErrorInvalid: u64 = 1;
    const ErrorNotStoreOwner: u64 = 2;
    const ErrorDuplicateUser: u64 = 3;
    const ErrorInsufficientBalance: u64 = 4;
    const ErrorStoreOwner: u64 = 5;

    public struct Store has key{
        id: UID,
        store_owner_cap: ID,
        balance: Balance<SUI>,
        owner_address: address,
        customers: vector<User>,
        customer_count: u64,
        items: vector<Perfume>,
        item_count: u64,
    }

    public struct StoreOwnerCapability has key{
        id: UID,
        store: ID,
    }
    public struct User has store{
        id: u64,
        name: String,
        user_address: address,
        order_count: u32,
        balance: Balance<SUI>,
    }

    public struct Perfume has store{
        id: u64,
        name: String,
        size: u64,
        price: u64,
        stock: u64,
    }

    public fun create_store(owner: address, ctx: &mut TxContext){
        let store_uid = object::new(ctx);
        let store_owner_cap_uid = object::new(ctx);

        let store_id = object::uid_to_inner(&store_uid);
        let store_owner_cap_id = object::uid_to_inner(&store_owner_cap_uid);

        transfer::transfer(StoreOwnerCapability{
            id: store_owner_cap_uid,
            store: store_id,
        }, owner);

        transfer::share_object(Store{
            id: store_uid,
            store_owner_cap: store_owner_cap_id,
            balance: balance::zero<SUI>(),
            owner_address: owner,
            customers: vector::empty(),
            customer_count: 0,
            items: vector::empty(),
            item_count: 0,
        })
    }

    public fun add_user(store: &mut Store,name: String, user_address: address, ctx: &mut TxContext){
        assert!(store.owner_address == ctx.sender(), ErrorNotStoreOwner);

        let mut x = 0;

        loop  {
            if(store.customers.length() == 0){
                break
            };

            let user = &store.customers[x];
            assert!(user.user_address != user_address, ErrorDuplicateUser);

            x = x + 1;
            if (x == store.customer_count) {
                break
            }
        };

        let id = store.customers.length();

        let user = User{
            id,
            name,
            user_address,
            order_count: 0,
            balance: balance::zero<SUI>(),
        };

        store.customers.push_back(user);
        store.customer_count = store.customer_count + 1;
    }

    public fun add_perfume(store: &mut Store, name: String, size: u64, price: u64, stock: u64, ctx: &mut TxContext){
        assert!(store.owner_address == ctx.sender(), ErrorNotStoreOwner);
        assert!(size>1, ErrorInvalid);
        assert!(stock> 0, ErrorInvalid);

        let id = store.items.length();
        let perfume = Perfume{
            id,
            name,
            size,
            price,
            stock,
        };

        store.items.push_back(perfume);
        store.item_count = store.item_count + 1;
    }

    public fun top_up_user_balance(store: &mut Store, user_id: u64, amount: u64,  payment: &mut coin::Coin<SUI>, ctx: &mut TxContext){
        assert!(store.owner_address != ctx.sender(), ErrorStoreOwner);

        assert!(user_id <= store.customers.length(), ErrorInvalid);
        let user = &mut store.customers[user_id];
        let top_up = payment.split(amount, ctx);
        coin::put(&mut user.balance, top_up);
    }

    public  fun purchase_perfume(store: &mut Store, user_id: u64, perfume_id: u64, quantity: u64, payment: &mut coin::Coin<SUI>, ctx: &mut TxContext){
        assert!(user_id <= store.customers.length(), ErrorInvalid);
        let user = &mut store.customers[user_id];

        assert!(perfume_id <= store.items.length(), ErrorInvalid);

        let perfume = &mut store.items[perfume_id];
        assert!(perfume.stock >= quantity, ErrorInvalid);

        let total_price = quantity * perfume.price;

        assert!(balance::value(&user.balance) >= total_price, ErrorInsufficientBalance);

        user.order_count = user.order_count + 1;

        perfume.stock = perfume.stock - quantity;

        let paid = payment.split(total_price, ctx);
        coin::put(&mut store.balance, paid);
    }
}
























