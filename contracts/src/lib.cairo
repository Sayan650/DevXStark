#[starknet::contract]
mod secure_contract {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use zeroable::Zeroable;
    use traits::Into;
    use option::OptionTrait;

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
        user: ContractAddress,
        value: u256,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct WhitelistUpdated {
        user: ContractAddress,
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
        fn set_value(ref self: ContractState, value: u256) {
            self.assert_not_paused();
            self.assert_whitelisted(get_caller_address());
            
            self.assert_non_zero_value(value);
            let caller = get_caller_address();
            self.values.write(caller, value);

            self.emit(ValueSet {
                user: caller,
                value,
                timestamp: get_block_timestamp(),
            });
        }

        fn get_value(self: @ContractState, user: ContractAddress) -> Option<u256> {
            self.assert_valid_user(user);
            self.values.read(user).into()
        }

        fn update_whitelist(ref self: ContractState, user: ContractAddress, status: bool) {
            self.assert_only_owner();
            self.assert_valid_user(user);
            
            self.whitelist.write(user, status);
            self.emit(WhitelistUpdated { user, status });
        }

        fn set_paused(ref self: ContractState, state: bool) {
            self.assert_only_admin_or_owner();
            self.paused.write(state);
            self.emit(PauseStateChanged { state });
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self.assert_only_owner();
            self.assert_valid_user(new_owner);
            
            let previous_owner = self.owner.read();
            self.owner.write(new_owner);
            
            self.emit(OwnershipTransferred { 
                previous_owner,
                new_owner
            });
        }

        fn is_whitelisted(self: @ContractState, user: ContractAddress) -> bool {
            self.whitelist.read(user)
        }

        fn is_paused(self: @ContractState) -> bool {
            self.paused.read()
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn assert_only_owner(ref self: ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not owner');
        }

        fn assert_only_admin(ref self: ContractState) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), 'Caller is not admin');
        }

        fn assert_only_admin_or_owner(ref self: ContractState) {
            let caller = get_caller_address();
            assert(
                caller == self.admin.read() || caller == self.owner.read(),
                'Caller is not admin or owner'
            );
        }

        fn assert_not_paused(ref self: ContractState) {
            assert(!self.paused.read(), 'Contract is paused');
        }

        fn assert_whitelisted(ref self: ContractState, user: ContractAddress) {
            assert(self.whitelist.read(user), 'User not whitelisted');
        }

        fn assert_valid_user(ref self: ContractState, user: ContractAddress) {
            assert(!user.is_zero(), 'Invalid user address');
        }

        fn assert_non_zero_value(ref self: ContractState, value: u256) {
            assert(value != 0.into(), 'Value cannot be zero');
        }
    }
}

#[starknet::interface]
trait IContract<TContractState> {
    fn set_value(ref self: TContractState, value: u256);
    fn get_value(self: @TContractState, user: ContractAddress) -> Option<u256>;
    fn update_whitelist(ref self: TContractState, user: ContractAddress, status: bool);
    fn set_paused(ref self: TContractState, state: bool);
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
    fn is_whitelisted(self: @TContractState, user: ContractAddress) -> bool;
    fn is_paused(self: @TContractState) -> bool;
}