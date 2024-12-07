```rust
#[starknet::contract]
mod secure_contract {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use zeroable::Zeroable;
    use traits::Into;
    
    #[storage]
    struct Storage {
        owner: ContractAddress,
        admins: LegacyMap<ContractAddress, bool>,
        value: u256,
        paused: bool,
        last_updated: u64,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ValueUpdated: ValueUpdated,
        AdminAdded: AdminAdded,
        AdminRemoved: AdminRemoved,
        ContractPaused: ContractPaused,
        ContractUnpaused: ContractUnpaused,
    }

    #[derive(Drop, starknet::Event)]
    struct ValueUpdated {
        old_value: u256,
        new_value: u256,
        updated_by: ContractAddress,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct AdminAdded {
        admin: ContractAddress,
        added_by: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct AdminRemoved {
        admin: ContractAddress,
        removed_by: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct ContractPaused {
        paused_by: ContractAddress,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct ContractUnpaused {
        unpaused_by: ContractAddress,
        timestamp: u64,
    }

    mod Errors {
        const INVALID_CALLER: felt252 = 'Caller is not authorized';
        const CONTRACT_PAUSED: felt252 = 'Contract is paused';
        const CONTRACT_UNPAUSED: felt252 = 'Contract is not paused';
        const INVALID_VALUE: felt252 = 'Invalid value provided';
        const ZERO_ADDRESS: felt252 = 'Zero address not allowed';
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        assert(!owner.is_zero(), Errors::ZERO_ADDRESS);
        self.owner.write(owner);
        self.admins.write(owner, true);
        self.paused.write(false);
        self.last_updated.write(get_block_timestamp());
    }

    #[abi(embed_v0)]
    impl SecureContract of super::ISecureContract<ContractState> {
        fn get_value(self: @ContractState) -> u256 {
            self.value.read()
        }

        fn set_value(ref self: ContractState, new_value: u256) {
            self.assert_not_paused();
            self.assert_admin();
            assert(new_value != 0, Errors::INVALID_VALUE);

            let old_value = self.value.read();
            self.value.write(new_value);
            self.last_updated.write(get_block_timestamp());

            self.emit(Event::ValueUpdated(ValueUpdated {
                old_value,
                new_value,
                updated_by: get_caller_address(),
                timestamp: get_block_timestamp(),
            }));
        }

        fn add_admin(ref self: ContractState, new_admin: ContractAddress) {
            self.assert_owner();
            assert(!new_admin.is_zero(), Errors::ZERO_ADDRESS);
            
            self.admins.write(new_admin, true);
            
            self.emit(Event::AdminAdded(AdminAdded {
                admin: new_admin,
                added_by: get_caller_address(),
            }));
        }

        fn remove_admin(ref self: ContractState, admin: ContractAddress) {
            self.assert_owner();
            assert(!admin.is_zero(), Errors::ZERO_ADDRESS);
            assert(admin != self.owner.read(), Errors::INVALID_CALLER);
            
            self.admins.write(admin, false);
            
            self.emit(Event::AdminRemoved(AdminRemoved {
                admin,
                removed_by: get_caller_address(),
            }));
        }

        fn pause(ref self: ContractState) {
            self.assert_admin();
            assert(!self.paused.read(), Errors::CONTRACT_PAUSED);
            
            self.paused.write(true);
            
            self.emit(Event::ContractPaused(ContractPaused {
                paused_by: get_caller_address(),
                timestamp: get_block_timestamp(),
            }));
        }

        fn unpause(ref self: ContractState) {
            self.assert_admin();
            assert(self.paused.read(), Errors::CONTRACT_UNPAUSED);
            
            self.paused.write(false);
            
            self.emit(Event::ContractUnpaused(ContractUnpaused {
                unpaused_by: get_caller_address(),
                timestamp: get_block_timestamp(),
            }));
        }

        fn is_admin(self: @ContractState, address: ContractAddress) -> bool {
            self.admins.read(address)
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn assert_owner(self: @ContractState) {
            assert(get_caller_address() == self.owner.read(), Errors::INVALID_CALLER);
        }

        fn assert_admin(self: @ContractState) {
            assert(self.admins.read(get_caller_address()), Errors::INVALID_CALLER);
        }

        fn assert_not_paused(self: @ContractState) {
            assert(!self.paused.read(), Errors::CONTRACT_PAUSED);
        }
    }
}

#[starknet::interface]
trait ISecureContract<TContractState> {
    fn get_value(self: @TContractState) -> u256;
    fn set_value(ref self: TContractState, new_value: u256);
    fn add_admin(ref self: TContractState, new_admin: ContractAddress);
    fn remove_admin(ref self: TContractState, admin: ContractAddress);
    fn pause(ref self: TContractState);
    fn unpause(ref self: TContractState);
    fn is_admin(self: @TContractState, address: ContractAddress) -> bool;
}
```