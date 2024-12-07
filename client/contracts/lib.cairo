  ```rust 
#[starknet::contract] 
mod secure_contract {
     use starknet::{Cont ractAddress, get_caller_ address, get_block_timestamp};
     use zeroable::Z eroable;
    use traits ::Into;
    
    #[storage ]
    struct Storage {
        owner : ContractAddress,
        admin : ContractAddress,
        pa used: bool,
        values: L egacyMap<ContractAddress, u 256>,
        total_supply: u256 ,
    }

    #[event ]
    #[derive(Drop, starknet::Event )]
    enum Event {
        Value Set: ValueSet,
        Ownership Transferred: OwnershipTransferred, 
        Paused: Paused,
         Unpaused: Unpaused, 
    }

    #[derive(Drop, stark net::Event)]
    struct ValueSet { 
        account: ContractAddress,
        previous _value: u256,
        new_ value: u256,
        timestamp: u 64,
    }

    #[derive (Drop, starknet::Event)] 
    struct OwnershipTransferred { 
        previous_owner: ContractAddress,
        new _owner: ContractAddress,
    } 

    #[derive(Drop, stark net::Event)]
    struct Pause d {
        account: ContractAddress,
     }

    #[derive(Drop, st arknet::Event)]
    struct Un paused {
        account: ContractAddress ,
    }

    mod Errors {
        const  INVALID_CALLER: felt252 = ' Caller is not authorized';
        const ZERO _ADDRESS: felt252 = 'Zero  address not allowed';
        const CONTRACT _PAUSED: felt252 =  'Contract is paused';
        const  INVALID_VALUE: felt252 = 'Invali d value provided';
        const OVERFLOW : felt252 = 'Arithmetic overflow ';
    }

    #[constructor ]
    fn constructor(ref self: Cont ractState, owner: ContractAddress) {
        assert (!owner.is_zero(), Errors::ZERO _ADDRESS);
        self.owner.write(owner); 
        self.admin.write(owner); 
        self.paused.write(false); 
        self.total_supply.write( 0);
    }

    #[ abi(embed_v0)]
    impl  SecureContract of super::ISecureContract<Cont ractState> {
        fn  get_value(self: @ContractState,  account: ContractAddress) -> u256  {
            assert(!account.is_ zero(), Errors::ZERO_ADDRESS); 
            self.values.read( account)
        }

        fn set_ value(ref self: ContractState, value : u256) {
            self .assert_not_paused(); 
            let caller = get_caller_ address();
            assert(!caller.is_zero (), Errors::ZERO_ADDRESS);
             
            let previous_value = self. values.read(caller);
             
            // Update total supply
            let new _total = self.total_supply.rea d() - previous_value + value;
            assert (new_total >= value, Errors:: OVERFLOW);
            
            self.values .write(caller, value);
            self .total_supply.write(new_total );

            self.emit(Event::ValueSet( 
                ValueSet {
                    account: caller, 
                    previous_value,
                    new _value: value,
                    timestamp:  get_block_timestamp(),
                }
            ));
         }

        fn transfer_ownership(ref self : ContractState, new_owner: Cont ractAddress) {
            self.assert_ only_owner();
            assert(!new_owner. is_zero(), Errors::ZERO_ ADDRESS);
            
            let previous_owner = self. owner.read();
            self.owner. write(new_owner);

            self.emit( Event::OwnershipTransferred( 
                OwnershipTransferred { previous_owner, new_ owner }
            ));
        } 

        fn pause(ref self: ContractState ) {
            self.assert_only_ admin();
            assert(!self.pause d.read(), 'Already paused');
             
            self.paused.write(true); 
            self.emit(Event::Pa used(Paused { account: get_ caller_address() }));
        } 

        fn unpause(ref self: Contract State) {
            self.assert_only _admin();
            assert(self.pa used.read(), 'Already unpaused'); 
            
            self.paused.write( false);
            self.emit(Event:: Unpaused(Unpaused {  account: get_caller_address() })); 
        }
    }

    #[generate _trait]
    impl InternalF unctions of InternalFunctionsTrait {
         fn assert_only_owner(self: @Cont ractState) {
            let caller = get _caller_address();
            assert(caller  == self.owner.read(), Errors:: INVALID_CALLER);
        } 

        fn assert_only_admin(self:  @ContractState) {
            let caller  = get_caller_address();
            assert (caller == self.admin.read(),  Errors::INVALID_CALLER);
         }

        fn assert_not_pause d(self: @ContractState) { 
            assert(!self.paused.read(),  Errors::CONTRACT_PAUSED); 
        }
    }
}

#[starknet ::interface]
trait ISecureContract <TContractState> {
    fn get_value(self : @TContractState, account: Cont ractAddress) -> u256;
    fn  set_value(ref self: TContractState, value: u 256);
    fn transfer_ownership(ref self: TContract State, new_owner: ContractAddress); 
    fn pause(ref self: TCont ractState);
    fn unpause(ref  self: TContractState);
} 
```  