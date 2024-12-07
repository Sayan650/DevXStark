```rust
use starknet::ContractAddress;

#[starknet::interface]
trait IContract<TContractState> {
    fn initialize(ref self: TContractState, owner: ContractAddress);
    fn set_admin(ref self: TContractState, new_admin: ContractAddress);
    fn get_admin(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
mod contract {
    use super::IContract;
    use starknet::{ContractAddress, get_caller_address};
    use zeroable::Zeroable;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        AdminChanged: AdminChanged,
        Initialized: Initialized,
    }

    #[derive(Drop, starknet::Event)]
    struct AdminChanged {
        previous_admin: ContractAddress,
        new_admin: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct Initialized {
        admin: ContractAddress
    }

    #[storage]
    struct Storage {
        initialized: bool,
        admin: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.initialized.write(false);
        self.admin.write(ContractAddress::zero());
    }

    #[external(v0)]
    impl ContractImpl of IContract<ContractState> {
        fn initialize(ref self: ContractState, owner: ContractAddress) {
            // Input validation
            assert(!owner.is_zero(), 'Owner cannot be zero');
            assert(!self.initialized.read(), 'Already initialized');

            // Set state
            self.initialized.write(true);
            self.admin.write(owner);

            // Emit event
            self.emit(Event::Initialized(Initialized { admin: owner }));
        }

        fn set_admin(ref self: ContractState, new_admin: ContractAddress) {
            // Input validation
            assert(!new_admin.is_zero(), 'Admin cannot be zero');
            
            // Access control
            self.only_admin();

            let previous_admin = self.admin.read();
            self.admin.write(new_admin);

            // Emit event
            self.emit(Event::AdminChanged(
                AdminChanged { 
                    previous_admin,
                    new_admin, 
                }
            ));
        }

        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn only_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), 'Caller is not admin');
        }
    }
}
```