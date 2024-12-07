  ```rust 
#[starknet::contract] 
mod secure_contract {
    use starknet: :{ContractAddress, get_caller_address, get_block _timestamp};
    use zeroable::Z eroable;
    use traits::Into;

    #[ event]
    #[derive(Drop,  starknet::Event)]
    enum Event  {
        ValueUpdated: ValueUpdated, 
        AdminChanged: AdminChanged,
        Paused: Pa used,
        Unpaused:  Unpaused
    }

    #[derive (Drop, starknet::Event)]
    struct ValueUpdate d {
        old_value: u256,
        new_ value: u256,
        updated_by: ContractAddress, 
        timestamp: u64
    }

    # [derive(Drop, starknet::Event)]
    struct Admin Changed {
        old_admin: ContractAddress,
        new _admin: ContractAddress,
        timestamp: u64
     }

    #[derive(Drop, starknet::Event)] 
    struct Paused {
        paused_ by: ContractAddress,
        timestamp:  u64
    }

    #[derive (Drop, starknet::Event)]
    struct Unpa used {
        unpaused_by:  ContractAddress,
        timestamp: u64 
    }

    #[storage]
    struct Storage  {
        admin: ContractAddress,
        value: u 256,
        paused: bool,
        last _update_time: u64,
        authorize d_users: LegacyMap::<ContractAddress,  bool>
    }

    #[constructor]
    fn constructor (ref self: ContractState, admin: ContractAddress ) {
        assert(!admin.is_zero(),  'Admin cannot be zero');
        self. admin.write(admin);
        self.pa used.write(false);
        self. value.write(0);
        self.last _update_time.write(0);
     }

    #[generate_trait] 
    impl Internal of InternalTrait {
        fn  assert_only_admin(self: @Cont ractState) {
            let caller = get_caller _address();
            assert(caller == self.admin. read(), 'Caller is not admin'); 
        }

        fn assert_not_ paused(self: @ContractState)  {
            assert(!self.paused.read(), ' Contract is paused');
        }

         fn assert_valid_address(address: Contract Address) {
            assert(!address.is_zero (), 'Invalid address');
        } 
    }

    #[abi(embed_v 0)]
    impl Contract of super::IContract<Cont ractState> {
        fn get_value(self: @Cont ractState) -> u256 {
             self.value.read()
        }

        fn set_value (ref self: ContractState, new_ value: u256) {
            self.assert_not _paused();
            assert(new_value >  0, 'Value must be positive'); 

            let caller = get_caller_address();
            assert (self.authorized_users.read(caller),  'User not authorized');

            let old_value =  self.value.read();
            self. value.write(new_value);
             self.last_update_time.write( get_block_timestamp());

            self .emit(Event::ValueUpdated( ValueUpdated {
                old_value, 
                new_value,
                updated_by : caller,
                timestamp: get_block_timestamp()
             }));
        }

        fn set_admin(ref self : ContractState, new_admin: Cont ractAddress) {
            self.assert_ only_admin();
            self.assert _valid_address(new_admin); 

            let old_admin = self.admin. read();
            self.admin.write( new_admin);

            self.emit( Event::AdminChanged(AdminChanged {
                 old_admin,
                new_admin, 
                timestamp: get_block_timestamp() 
            }));
        }

        fn  authorize_user(ref self: ContractState,  user: ContractAddress) {
            self .assert_only_admin();
            self .assert_valid_address(user);
            self .authorized_users.write(user, true );
        }

        fn revoke_ user(ref self: ContractState, user : ContractAddress) {
            self. assert_only_admin();
            self.assert_valid_address (user);
            self.authorized_users.write(user,  false);
        }

        fn pause(ref self: Contract State) {
            self.assert_only _admin();
            assert(!self.pause d.read(), 'Already paused');
             self.paused.write(true); 

            self.emit(Event::Pause d(Paused {
                paused_ by: get_caller_address(),
                 timestamp: get_block_timestamp()
             }));
        }

        fn unpause (ref self: ContractState) { 
            self.assert_only_admin(); 
            assert(self.paused.read(),  'Already unpaused');
            self.pause d.write(false);

            self.emit (Event::Unpaused(Un paused {
                unpaused_by : get_caller_address(),
                timestamp : get_block_timestamp()
            } ));
        }

        fn get_last _update_time(self: @Contract State) -> u64 {
            self .last_update_time.read() 
        }

        fn is_authorize d(self: @ContractState, user:  ContractAddress) -> bool {
            self .authorized_users.read(user) 
        }
    }
} 

#[starknet::interface]
trait IContract <TContractState> {
    fn  get_value(self: @TContract State) -> u256;
    fn  set_value(ref self: TContract State, new_value: u256); 
    fn set_admin(ref self: T ContractState, new_admin: Contract Address);
    fn authorize_user(ref  self: TContractState, user: Cont ractAddress);
    fn revoke_user (ref self: TContractState, user : ContractAddress);
    fn pause( ref self: TContractState);
     fn unpause(ref self: TContract State);
    fn get_last_update _time(self: @TContractState ) -> u64;
    fn is_ authorized(self: @TContractState,  user: ContractAddress) -> bool; 
}
```  