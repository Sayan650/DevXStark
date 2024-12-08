#[starknet::contract]
mod contract {
    use starknet::{
        ContractAddress,
        get_caller_address,
        get_contract_address,
        contract_address_const
    };
    use core::traits::Into;
    use core::option::OptionTrait;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        paused: bool,
        whitelist: LegacyMap<ContractAddress, bool>,
        balances: LegacyMap<ContractAddress, u256>,
        total_supply: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        OwnershipTransferred: OwnershipTransferred,
        PauseStateChanged: PauseStateChanged,
        WhitelistUpdated: WhitelistUpdated,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct PauseStateChanged {
        state: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct WhitelistUpdated {
        account: ContractAddress,
        status: bool,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        assert(!initial_owner.is_zero(), 'Owner cannot be zero');
        self.owner.write(initial_owner);
        self.paused.write(false);
        self.total_supply.write(0);
    }

    #[external(v0)]
    impl ContractImpl of super::IContract<ContractState> {
        fn transfer(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            self.assert_not_paused();
            let caller = get_caller_address();
            self.assert_whitelisted(caller);
            self.assert_whitelisted(to);
            
            assert(!to.is_zero(), 'Transfer to zero address');
            let caller_balance = self.balances.read(caller);
            assert(caller_balance >= amount, 'Insufficient balance');

            self.balances.write(caller, caller_balance - amount);
            self.balances.write(to, self.balances.read(to) + amount);

            self.emit(Transfer { from: caller, to, amount });
            true
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self.assert_only_owner();
            assert(!new_owner.is_zero(), 'New owner cannot be zero');
            let previous_owner = self.owner.read();
            self.owner.write(new_owner);
            self.emit(OwnershipTransferred { previous_owner, new_owner });
        }

        fn set_pause(ref self: ContractState, state: bool) {
            self.assert_only_owner();
            self.paused.write(state);
            self.emit(PauseStateChanged { state });
        }

        fn update_whitelist(ref self: ContractState, account: ContractAddress, status: bool) {
            self.assert_only_owner();
            assert(!account.is_zero(), 'Account cannot be zero');
            self.whitelist.write(account, status);
            self.emit(WhitelistUpdated { account, status });
        }

        fn is_whitelisted(self: @ContractState, account: ContractAddress) -> bool {
            self.whitelist.read(account)
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not owner');
        }

        fn assert_not_paused(self: @ContractState) {
            assert(!self.paused.read(), 'Contract is paused');
        }

        fn assert_whitelisted(self: @ContractState, account: ContractAddress) {
            assert(self.whitelist.read(account), 'Account not whitelisted');
        }
    }
}

#[starknet::interface]
trait IContract<TContractState> {
    fn transfer(ref self: TContractState, to: ContractAddress, amount: u256) -> bool;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn total_supply(self: @TContractState) -> u256;
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
    fn set_pause(ref self: TContractState, state: bool);
    fn update_whitelist(ref self: TContractState, account: ContractAddress, status: bool);
    fn is_whitelisted(self: @TContractState, account: ContractAddress) -> bool;
}