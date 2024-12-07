```rust
#[starknet::contract]
mod secure_contract {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use zeroable::Zeroable;
    use traits::Into;
    
    #[storage]
    struct Storage {
        owner: ContractAddress,
        admin: ContractAddress,
        paused: bool,
        values: LegacyMap<ContractAddress, u256>,
        whitelist: LegacyMap<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ValueSet: ValueSet,
        WhitelistUpdated: WhitelistUpdated,
        PauseStateChanged: PauseStateChanged,
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct ValueSet {
        account: ContractAddress,
        value: u256,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct WhitelistUpdated {
        account: ContractAddress,
        status: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct PauseStateChanged {
        state: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        assert(!owner.is_zero(), 'Owner cannot be zero');
        self.owner.write(owner);
        self.admin.write(owner);
        self.paused.write(false);
    }

    #[abi(embed_v0)]
    impl Contract of super::IContract<ContractState> {
        fn get_value(self: @ContractState, account: ContractAddress) -> u256 {
            assert(!account.is_zero(), 'Invalid account');
            self.values.read(account)
        }

        fn set_value(ref self: ContractState, value: u256) {
            self.assert_not_paused();
            self.assert_whitelisted(get_caller_address());
            
            let caller = get_caller_address();
            self.values.write(caller, value);

            self.emit(ValueSet {
                account: caller,
                value,
                timestamp: get_block_timestamp(),
            });
        }

        fn update_whitelist(ref self: ContractState, account: ContractAddress, status: bool) {
            self.assert_only_admin();
            assert(!account.is_zero(), 'Invalid account');
            
            self.whitelist.write(account, status);
            
            self.emit(WhitelistUpdated { account, status });
        }

        fn set_paused(ref self: ContractState, state: bool) {
            self.assert_only_owner();
            self.paused.write(state);
            
            self.emit(PauseStateChanged { state });
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self.assert_only_owner();
            assert(!new_owner.is_zero(), 'Invalid new owner');
            
            let previous_owner = self.owner.read();
            self.owner.write(new_owner);
            
            self.emit(OwnershipTransferred { 
                previous_owner,
                new_owner
            });
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn is_whitelisted(self: @ContractState, account: ContractAddress) -> bool {
            self.whitelist.read(account)
        }

        fn is_paused(self: @ContractState) -> bool {
            self.paused.read()
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not owner');
        }

        fn assert_only_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), 'Caller is not admin');
        }

        fn assert_whitelisted(self: @ContractState, account: ContractAddress) {
            assert(self.whitelist.read(account), 'Account not whitelisted');
        }

        fn assert_not_paused(self: @ContractState) {
            assert(!self.paused.read(), 'Contract is paused');
        }
    }
}

#[starknet::interface]
trait IContract<TContractState> {
    fn get_value(self: @TContractState, account: ContractAddress) -> u256;
    fn set_value(ref self: TContractState, value: u256);
    fn update_whitelist(ref self: TContractState, account: ContractAddress, status: bool);
    fn set_paused(ref self: TContractState, state: bool);
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn is_whitelisted(self: @TContractState, account: ContractAddress) -> bool;
    fn is_paused(self: @TContractState) -> bool;
}
```