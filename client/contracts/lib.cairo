  # [starknet::contract]
mod contract { 
    use starknet::{ContractAddress, get _caller_address};
    use z eroable::Zeroable; 
    use array::ArrayTrait;
     use traits::Into;

    #[storage]
    struct  Storage {
        owner: ContractAddress, 
        admins: LegacyMap ::<ContractAddress, bool>,
        is _paused: bool,
    }

    #[ event]
    #[derive(Drop , starknet::Event)]
    enum  Event {
        AdminAdded: AdminAdded,
         AdminRemoved: AdminRemoved,
         ContractPaused: ContractPause d,
        ContractUnpaused: Cont ractUnpaused,
    }

     #[derive(Drop, starknet::Event )]
    struct AdminAdded {
        admin: Cont ractAddress,
        timestamp: u64, 
    }

    #[derive(Drop,  starknet::Event)]
    struct Admin Removed {
        admin: ContractAddress ,
        timestamp: u64,
     }

    #[derive(Drop, st arknet::Event)]
    struct Contract Paused {
        timestamp: u64 ,
    }

    #[derive( Drop, starknet::Event)]
     struct ContractUnpaused {
        timestamp : u64,
    }

    mo d Errors {
        const INVALID _ADDRESS: felt252 = 'Invali d address';
        const UNAUTHORIZED: felt252  = 'Unauthorized';
        const  ALREADY_ADMIN: felt252 =  'Already an admin';
        const  NOT_ADMIN: felt252 =  'Not an admin';
        const CONTRACT _PAUSED: felt252 =  'Contract is paused';
        const CONTRACT _NOT_PAUSED: felt252 =  'Contract not paused';
    }

    #[ constructor]
    fn constructor(ref self: Cont ractState, owner: ContractAddress) {
        assert (!owner.is_zero(), Errors::INVALID _ADDRESS);
        self.owner. write(owner);
        self.admins .write(owner, true);
         self.is_paused.write(false );
    }

    #[external( v0)]
    fn add_admin(ref self : ContractState, new_admin: Contract Address) {
        self.only_owner();
         assert(!new_admin.is_zero(),  Errors::INVALID_ADDRESS);
         assert(!self.admins.read(new_ admin), Errors::ALREADY_ADMIN );

        self.admins.write(new_ admin, true);
        self.emit(Event:: AdminAdded(AdminAdded { admin:  new_admin, timestamp: starknet::get_ block_timestamp() }));
    } 

    #[external(v0)]
     fn remove_admin(ref self: Contract State, admin: ContractAddress) { 
        self.only_owner();
        assert (self.admins.read(admin),  Errors::NOT_ADMIN);
        assert (admin != self.owner. read(), Errors::UNAUTHORIZED);

         self.admins.write(admin, false );
        self.emit(Event::Admin Removed(AdminRemoved { admin,  timestamp: starknet::get_block_ timestamp() }));
    }

    # [external(v0)]
    fn pause (ref self: ContractState) { 
        self.only_admin();
        assert (!self.is_paused.read(),  Errors::CONTRACT_PAUSED); 

        self.is_paused.write( true);
        self.emit(Event:: ContractPaused(ContractPa used { timestamp: starknet::get_ block_timestamp() }));
    } 

    #[external(v0)]
     fn unpause(ref self: ContractState ) {
        self.only_admin(); 
        assert(self.is_pause d.read(), Errors::CONTRACT_NOT_ PAUSED);

        self.is_ paused.write(false);
        self .emit(Event::ContractUnpause d(ContractUnpaused { timestamp: st arknet::get_block_timestamp() } ));
    }

    #[view]
    fn is _admin(self: @Cont ractState, address: ContractAddress)  -> bool {
        self.admins. read(address)
    }

    # [view]
    fn get_owner(self:  @ContractState) -> ContractAddress { 
        self.owner.read()
     }

    #[view]
    fn  is_contract_paused(self : @ContractState) -> bool { 
        self.is_paused.read() 
    }

    trait InternalFunctions {
         fn only_owner(ref  self: ContractState);
        fn only_ admin(ref self: ContractState); 
    }

    impl InternalFunct ionsImpl of InternalFunctions { 
        fn only_owner(ref self:  ContractState) {
            let caller =  get_caller_address();
            assert( caller == self.owner.read(), Errors ::UNAUTHORIZED);
        }

        fn  only_admin(ref self: ContractState ) {
            let caller = get_caller _address();
            assert(self.adm ins.read(caller), Errors:: UNAUTHORIZED);
        } 
    }
}  