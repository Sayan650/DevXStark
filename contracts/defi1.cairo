#[starknet::contract]
mod secure_contract {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use zeroable::Zeroable;
    use traits::Into;
    use array::ArrayTrait;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        admin_mapping: LegacyMap<ContractAddress, bool>,
        value: u256,
        is_paused: bool,
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
        const ZERO_ADDRESS: felt252 = 'Zero address not allowed';
        const CONTRACT_PAUSED: felt252 = 'Contract is paused';
        const INVALID_VALUE: felt252 = 'Invalid value provided';
        const ALREADY_ADMIN: felt252 = 'Address is already admin';
        const NOT_ADMIN: felt252 = 'Address is not admin';
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        assert(!owner.is_zero(), Errors::ZERO_ADDRESS);
        self.owner.write(owner);
        self.admin_mapping.write(owner, true);
        self.is_paused.write(false);
    }

    #[external(v0)]
    fn set_value(ref self: ContractState, new_value: u256) {
        // Validate caller
        let caller = get_caller_address();
        assert(self.admin_mapping.read(caller), Errors::INVALID_CALLER);
        
        // Check contract state
        assert(!self.is_paused.read(), Errors::CONTRACT_PAUSED);
        
        // Validate input
        assert(new_value != 0, Errors::INVALID_VALUE);

        // Update state
        let old_value = self.value.read();
        self.value.write(new_value);

        // Emit event
        self.emit(Event::ValueUpdated(ValueUpdated {
            old_value,
            new_value,
            updated_by: caller,
            timestamp: get_block_timestamp(),
        }));
    }

    #[external(v0)]
    fn add_admin(ref self: ContractState, new_admin: ContractAddress) {
        let caller = get_caller_address();
        assert(caller == self.owner.read(), Errors::INVALID_CALLER);
        assert(!new_admin.is_zero(), Errors::ZERO_ADDRESS);
        assert(!self.admin_mapping.read(new_admin), Errors::ALREADY_ADMIN);

        self.admin_mapping.write(new_admin, true);
        
        self.emit(Event::AdminAdded(AdminAdded { 
            admin: new_admin, 
            added_by: caller 
        }));
    }

    #[external(v0)]
    fn remove_admin(ref self: ContractState, admin: ContractAddress) {
        let caller = get_caller_address();
        assert(caller == self.owner.read(), Errors::INVALID_CALLER);
        assert(!admin.is_zero(), Errors::ZERO_ADDRESS);
        assert(self.admin_mapping.read(admin), Errors::NOT_ADMIN);
        assert(admin != self.owner.read(), 'Cannot remove owner');

        self.admin_mapping.write(admin, false);
        
        self.emit(Event::AdminRemoved(AdminRemoved {
            admin,
            removed_by: caller
        }));
    }

    #[external(v0)]
    fn pause(ref self: ContractState) {
        let caller = get_caller_address();
        assert(self.admin_mapping.read(caller), Errors::INVALID_CALLER);
        assert(!self.is_paused.read(), 'Already paused');

        self.is_paused.write(true);
        
        self.emit(Event::ContractPaused(ContractPaused {
            paused_by: caller,
            timestamp: get_block_timestamp(),
        }));
    }

    #[external(v0)]
    fn unpause(ref self: ContractState) {
        let caller = get_caller_address();
        assert(self.admin_mapping.read(caller), Errors::INVALID_CALLER);
        assert(self.is_paused.read(), 'Not paused');

        self.is_paused.write(false);
        
        self.emit(Event::ContractUnpaused(ContractUnpaused {
            unpaused_by: caller,
            timestamp: get_block_timestamp(),
        }));
    }
}