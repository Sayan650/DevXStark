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
        allowed_operators: LegacyMap<ContractAddress, bool>,
        total_supply: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ValueSet: ValueSet,
        OperatorUpdated: OperatorUpdated,
        Paused: Paused,
        Unpaused: Unpaused,
    }

    #[derive(Drop, starknet::Event)]
    struct ValueSet {
        account: ContractAddress,
        previous_value: u256,
        new_value: u256,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct OperatorUpdated {
        operator: ContractAddress,
        status: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct Paused {
        by: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct Unpaused {
        by: ContractAddress,
    }

    mod Errors {
        const INVALID_CALLER: felt252 = 'Caller is not authorized';
        const CONTRACT_PAUSED: felt252 = 'Contract is paused';
        const INVALID_VALUE: felt252 = 'Invalid value provided';
        const ZERO_ADDRESS: felt252 = 'Zero address not allowed';
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, admin: ContractAddress) {
        assert(!owner.is_zero(), Errors::ZERO_ADDRESS);
        assert(!admin.is_zero(), Errors::ZERO_ADDRESS);
        self.owner.write(owner);
        self.admin.write(admin);
        self.paused.write(false);
        self.total_supply.write(0);
    }

    #[abi(embed_v0)]
    impl Contract of super::IContract<ContractState> {
        fn get_value(self: @ContractState, account: ContractAddress) -> u256 {
            assert(!account.is_zero(), Errors::ZERO_ADDRESS);
            self.values.read(account)
        }

        fn set_value(ref self: ContractState, account: ContractAddress, value: u256) {
            self.assert_not_paused();
            self.assert_only_operator();
            assert(!account.is_zero(), Errors::ZERO_ADDRESS);
            
            let previous_value = self.values.read(account);
            self.values.write(account, value);
            
            self.emit(ValueSet {
                account: account,
                previous_value: previous_value,
                new_value: value,
                timestamp: get_block_timestamp(),
            });
        }

        fn add_operator(ref self: ContractState, operator: ContractAddress) {
            self.assert_only_owner();
            assert(!operator.is_zero(), Errors::ZERO_ADDRESS);
            
            self.allowed_operators.write(operator, true);
            
            self.emit(OperatorUpdated {
                operator: operator,
                status: true,
            });
        }

        fn remove_operator(ref self: ContractState, operator: ContractAddress) {
            self.assert_only_owner();
            assert(!operator.is_zero(), Errors::ZERO_ADDRESS);
            
            self.allowed_operators.write(operator, false);
            
            self.emit(OperatorUpdated {
                operator: operator,
                status: false,
            });
        }

        fn pause(ref self: ContractState) {
            self.assert_only_admin();
            self.paused.write(true);
            
            self.emit(Paused { 
                by: get_caller_address() 
            });
        }

        fn unpause(ref self: ContractState) {
            self.assert_only_admin();
            self.paused.write(false);
            
            self.emit(Unpaused { 
                by: get_caller_address() 
            });
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), Errors::INVALID_CALLER);
        }

        fn assert_only_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), Errors::INVALID_CALLER);
        }

        fn assert_only_operator(self: @ContractState) {
            let caller = get_caller_address();
            assert(
                self.allowed_operators.read(caller) || caller == self.owner.read(),
                Errors::INVALID_CALLER
            );
        }

        fn assert_not_paused(ref self: ContractState) {
            assert(!self.paused.read(), Errors::CONTRACT_PAUSED);
        }
    }
}

#[starknet::interface]
trait IContract<TContractState> {
    fn get_value(self: @TContractState, account: ContractAddress) -> u256;
    fn set_value(ref self: TContractState, account: ContractAddress, value: u256);
    fn add_operator(ref self: TContractState, operator: ContractAddress);
    fn remove_operator(ref self: TContractState, operator: ContractAddress);
    fn pause(ref self: TContractState);
    fn unpause(ref self: TContractState);
}