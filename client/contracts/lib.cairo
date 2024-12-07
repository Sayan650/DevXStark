```rust
#[starknet::contract]
mod secure_contract {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use zeroable::Zeroable;
    use traits::Into;
    
    #[storage]
    struct Storage {
        owner: ContractAddress,
        authorized_operators: LegacyMap<ContractAddress, bool>,
        value: u256,
        paused: bool,
        last_updated: u64,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ValueUpdated: ValueUpdated,
        OperatorStatusChanged: OperatorStatusChanged,
        OwnershipTransferred: OwnershipTransferred,
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
    struct OperatorStatusChanged {
        operator: ContractAddress,
        status: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct ContractPaused {
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct ContractUnpaused {
        timestamp: u64,
    }

    mod Errors {
        const INVALID_CALLER: felt252 = 'Caller is not authorized';
        const INVALID_VALUE: felt252 = 'Invalid value provided';
        const CONTRACT_PAUSED: felt252 = 'Contract is paused';
        const ZERO_ADDRESS: felt252 = 'Zero address not allowed';
        const ALREADY_INITIALIZED: felt252 = 'Already initialized';
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        assert(!initial_owner.is_zero(), Errors::ZERO_ADDRESS);
        self.owner.write(initial_owner);
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
            self.assert_authorized();
            assert(new_value != 0, Errors::INVALID_VALUE);

            let old_value = self.value.read();
            self.value.write(new_value);
            self.last_updated.write(get_block_timestamp());

            self.emit(Event::ValueUpdated(
                ValueUpdated {
                    old_value,
                    new_value,
                    updated_by: get_caller_address(),
                    timestamp: get_block_timestamp()
                }
            ));
        }

        fn add_operator(ref self: ContractState, operator: ContractAddress) {
            self.assert_only_owner();
            assert(!operator.is_zero(), Errors::ZERO_ADDRESS);
            
            self.authorized_operators.write(operator, true);
            
            self.emit(Event::OperatorStatusChanged(
                OperatorStatusChanged { operator, status: true }
            ));
        }

        fn remove_operator(ref self: ContractState, operator: ContractAddress) {
            self.assert_only_owner();
            assert(!operator.is_zero(), Errors::ZERO_ADDRESS);
            
            self.authorized_operators.write(operator, false);
            
            self.emit(Event::OperatorStatusChanged(
                OperatorStatusChanged { operator, status: false }
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

        fn pause(ref self: ContractState) {
            self.assert_only_owner();
            self.paused.write(true);
            self.emit(Event::ContractPaused(ContractPaused { timestamp: get_block_timestamp() }));
        }

        fn unpause(ref self: ContractState) {
            self.assert_only_owner();
            self.paused.write(false);
            self.emit(Event::ContractUnpaused(ContractUnpaused { timestamp: get_block_timestamp() }));
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn assert_only_owner(self: @ContractState) {
            assert(get_caller_address() == self.owner.read(), Errors::INVALID_CALLER);
        }

        fn assert_authorized(self: @ContractState) {
            let caller = get_caller_address();
            assert(
                caller == self.owner.read() || self.authorized_operators.read(caller),
                Errors::INVALID_CALLER
            );
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
    fn add_operator(ref self: TContractState, operator: ContractAddress);
    fn remove_operator(ref self: TContractState, operator: ContractAddress);
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
    fn pause(ref self: TContractState);
    fn unpause(ref self: TContractState);
}
```