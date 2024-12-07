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
    fn constructor(ref self: ContractState, owner: ContractAddress, admin: ContractAddress) {
        assert(!owner.is_zero(), Errors::ZERO_ADDRESS);
        assert(!admin.is_zero(), Errors::ZERO_ADDRESS);
        self.owner.write(owner);
        self.admin.write(admin);
        self.paused::write(false); // Initialize paused state
    }

    #[external]
    fn update_value(ref self: ContractState, new_value: u256) {
        assert(!self.paused.read(), Errors::CONTRACT_PAUSED);
        assert(self.is_whitelisted(get_caller_address()), Errors::NOT_WHITELISTED);

        let old_value = self.value.read();
        self.value.write(new_value);

        self.emit(Event::ValueUpdated(ValueUpdated { 
            old_value: old_value,
            new_value: new_value, 
            updated_by: get_caller_address(),
            timestamp: get_block_timestamp()
        }));
    }
    
    #[external]
    fn whitelist_account(ref self: ContractState, account: ContractAddress, status: bool) {
        assert(self.is_authorized_caller(), Errors::INVALID_CALLER);
        
        self.whitelist.write(account, status);
        
        self.emit(Event::WhitelistUpdated(WhitelistUpdated { 
            account: account,
            status: status
        }));
    }
    
    #[external]
    fn pause(ref self: ContractState) {
        assert(self.is_authorized_caller(), Errors::INVALID_CALLER);
        assert(!self.paused.read(), Errors::CONTRACT_PAUSED);
        
        self.paused.write(true);
        
        self.emit(Event::PauseStateChanged(PauseStateChanged { 
            state: true,
            timestamp: get_block_timestamp()
        }));
    }

    #[external]
    fn unpause(ref self: ContractState) {
        assert(self.is_authorized_caller(), Errors::INVALID_CALLER);
        assert(self.paused.read(), Errors::CONTRACT_PAUSED); // Check if already paused
        
        self.paused.write(false);
        
        self.emit(Event::PauseStateChanged(PauseStateChanged { 
            state: false,
            timestamp: get_block_timestamp()
        }));
    }

    #[external]
    fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
        assert(self.is_owner(), Errors::INVALID_CALLER);
        assert(!new_owner.is_zero(), Errors::ZERO_ADDRESS);
        
        let previous_owner = self.owner.read();
        self.owner.write(new_owner);
        
        self.emit(Event::OwnershipTransferred(OwnershipTransferred { 
            previous_owner: previous_owner,
            new_owner: new_owner
        }));
    }

    fn is_owner(self: @ContractState) -> bool {
        self.owner.read() == get_caller_address()
    }

    fn is_admin(self: @ContractState) -> bool {
        self.admin.read() == get_caller_address()
    }
    
    fn is_authorized_caller(self: @ContractState) -> bool {
        self.is_owner() || self.is_admin()
    }

    fn is_whitelisted(self: @ContractState, account: ContractAddress) -> bool {
        self.whitelist.read(account)
    }
}
