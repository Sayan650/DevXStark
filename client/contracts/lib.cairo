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
        value: u256,
        whitelist: LegacyMap<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ValueUpdated: ValueUpdated,
        WhitelistUpdated: WhitelistUpdated,
        PauseStateChanged: PauseStateChanged,
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct ValueUpdated {
        old_value: u256,
        new_value: u256,
        updated_by: ContractAddress,
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
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    mod Errors {
        const INVALID_CALLER: felt252 = 'Caller is not authorized';
        const CONTRACT_PAUSED: felt252 = 'Contract is paused';
        const INVALID_VALUE: felt252 = 'Invalid value provided';
        const ZERO_ADDRESS: felt252 = 'Zero address not allowed';
        const NOT_WHITELISTED: felt252 = 'Address not whitelisted';
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        assert(!owner.is_zero(), Errors::ZERO_ADDRESS);
        self.owner.write(owner);
        self.admin.write(owner);
        self.paused.write(false);
    }

    #[abi(embed_v0)]
    impl SecureContract of super::ISecureContract<ContractState> {
        fn get_value(self: @ContractState) -> u256 {
            self.value.read()
        }

        fn set_value(ref self: ContractState, new_value: u256) {
            self.assert_not_paused();
            self.assert_whitelisted();
            assert(new_value != 0, Errors::INVALID_VALUE);

            let caller = get_caller_address();
            let old_value = self.value.read();
            
            self.value.write(new_value);

            self.emit(Event::ValueUpdated(
                ValueUpdated {
                    old_value,
                    new_value,
                    updated_by: caller,
                    timestamp: get_block_timestamp(),
                }
            ));
        }

        fn add_to_whitelist(ref self: ContractState, account: ContractAddress) {
            self.assert_only_owner();
            assert(!account.is_zero(), Errors::ZERO_ADDRESS);
            
            self.whitelist.write(account, true);
            
            self.emit(Event::WhitelistUpdated(
                WhitelistUpdated { account, status: true }
            ));
        }

        fn remove_from_whitelist(ref self: ContractState, account: ContractAddress) {
            self.assert_only_owner();
            assert(!account.is_zero(), Errors::ZERO_ADDRESS);
            
            self.whitelist.write(account, false);
            
            self.emit(Event::WhitelistUpdated(
                WhitelistUpdated { account, status: false }
            ));
        }

        fn set_paused(ref self: ContractState, state: bool) {
            self.assert_only_admin();
            self.paused.write(state);
            
            self.emit(Event::PauseStateChanged(
                PauseStateChanged { 
                    state,
                    timestamp: get_block_timestamp()
                }
            ));
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self.assert_only_owner();
            assert(!new_owner.is_zero(), Errors::ZERO_ADDRESS);
            
            let previous_owner = self.owner.read();
            self.owner.write(new_owner);
            
            self.emit(Event::OwnershipTransferred(
                OwnershipTransferred { previous_owner, new_owner }
            ));
        }

        fn is_whitelisted(self: @ContractState, account: ContractAddress) -> bool {
            self.whitelist.read(account)
        }

        fn is_paused(self: @ContractState) -> bool {
            self.paused.read()
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn assert_only_owner(ref self: ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), Errors::INVALID_CALLER);
        }

        fn assert_only_admin(ref self: ContractState) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), Errors::INVALID_CALLER);
        }

        fn assert_not_paused(ref self: ContractState) {
            assert(!self.paused.read(), Errors::CONTRACT_PAUSED);
        }

        fn assert_whitelisted(ref self: ContractState) {
            let caller = get_caller_address();
            assert(self.whitelist.read(caller), Errors::NOT_WHITELISTED);
        }
    }
}

#[starknet::interface]
trait ISecureContract<TContractState> {
    fn get_value(self: @TContractState) -> u256;
    fn set_value(ref self: TContractState, new_value: u256);
    fn add_to_whitelist(ref self: TContractState, account: ContractAddress);
    fn remove_from_whitelist(ref self: TContractState, account: ContractAddress);
    fn set_paused(ref self: TContractState, state: bool);
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
    fn is_whitelisted(self: @TContractState, account: ContractAddress) -> bool;
    fn is_paused(self: @TContractState) -> bool;
    fn get_owner(self: @TContractState) -> ContractAddress;
}
```