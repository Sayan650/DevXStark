#[starknet::contract]
mod secure_contract {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use zeroable::Zeroable;
    use traits::Into;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ValueUpdated: ValueUpdated,
        AdminChanged: AdminChanged,
        Paused: Paused,
        Unpaused: Unpaused
    }

    #[derive(Drop, starknet::Event)]
    struct ValueUpdated {
        old_value: u256,
        new_value: u256,
        updated_by: ContractAddress,
        timestamp: u64
    }

    #[derive(Drop, starknet::Event)]
    struct AdminChanged {
        old_admin: ContractAddress,
        new_admin: ContractAddress,
        timestamp: u64
    }

    #[derive(Drop, starknet::Event)]
    struct Paused {
        paused_by: ContractAddress,
        timestamp: u64
    }

    #[derive(Drop, starknet::Event)]
    struct Unpaused {
        unpaused_by: ContractAddress,
        timestamp: u64
    }

    #[storage]
    struct Storage {
        admin: ContractAddress,
        value: u256,
        paused: bool,
        authorized_users: LegacyMap<ContractAddress, bool>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        assert(!admin.is_zero(), 'Admin cannot be zero');
        self.admin.write(admin);
        self.paused.write(false);
        self.authorized_users.write(admin, true);
    }

    #[abi(embed_v0)]
    impl SecureContract of super::ISecureContract<ContractState> {
        fn get_value(self: @ContractState) -> u256 {
            self.value.read()
        }

        fn set_value(ref self: ContractState, new_value: u256) {
            self.assert_not_paused();
            self.assert_authorized();

            let caller = get_caller_address();
            let old_value = self.value.read();
            
            assert(new_value > 0, 'Value must be positive');

            self.value.write(new_value);

            self.emit(Event::ValueUpdated(
                ValueUpdated {
                    old_value,
                    new_value,
                    updated_by: caller,
                    timestamp: get_block_timestamp()
                }
            ));
        }

        fn add_authorized_user(ref self: ContractState, user: ContractAddress) {
            self.assert_only_admin();
            assert(!user.is_zero(), 'User cannot be zero');
            self.authorized_users.write(user, true);
        }

        fn remove_authorized_user(ref self: ContractState, user: ContractAddress) {
            self.assert_only_admin();
            assert(!user.is_zero(), 'User cannot be zero');
            assert(user != self.admin.read(), 'Cannot remove admin');
            self.authorized_users.write(user, false);
        }

        fn change_admin(ref self: ContractState, new_admin: ContractAddress) {
            self.assert_only_admin();
            assert(!new_admin.is_zero(), 'Admin cannot be zero');
            
            let old_admin = self.admin.read();
            self.admin.write(new_admin);
            self.authorized_users.write(old_admin, false);
            self.authorized_users.write(new_admin, true);

            self.emit(Event::AdminChanged(
                AdminChanged {
                    old_admin,
                    new_admin,
                    timestamp: get_block_timestamp()
                }
            ));
        }

        fn pause(ref self: ContractState) {
            self.assert_only_admin();
            assert(!self.paused.read(), 'Already paused');
            
            self.paused.write(true);
            
            self.emit(Event::Paused(
                Paused {
                    paused_by: get_caller_address(),
                    timestamp: get_block_timestamp()
                }
            ));
        }

        fn unpause(ref self: ContractState) {
            self.assert_only_admin();
            assert(self.paused.read(), 'Not paused');
            
            self.paused.write(false);
            
            self.emit(Event::Unpaused(
                Unpaused {
                    unpaused_by: get_caller_address(),
                    timestamp: get_block_timestamp()
                }
            ));
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn assert_only_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), 'Caller is not admin');
        }

        fn assert_authorized(self: @ContractState) {
            let caller = get_caller_address();
            assert(
                self.authorized_users.read(caller),
                'Caller not authorized'
            );
        }

        fn assert_not_paused(self: @ContractState) {
            assert(!self.paused.read(), 'Contract is paused');
        }
    }
}

#[starknet::interface]
trait ISecureContract<TContractState> {
    fn get_value(self: @TContractState) -> u256;
    fn set_value(ref self: TContractState, new_value: u256);
    fn add_authorized_user(ref self: TContractState, user: ContractAddress);
    fn remove_authorized_user(ref self: TContractState, user: ContractAddress);
    fn change_admin(ref self: TContractState, new_admin: ContractAddress);
    fn pause(ref self: TContractState);
    fn unpause(ref self: TContractState);
}