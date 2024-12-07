  ```rust 
#[stark net::contract] 
mod secure _contract {
     use starknet: :{ContractAddress, get _caller_address,  get_block _timestamp};
     use zeroable::Z eroable; 
    use traits ::Into; 
     
    #[storage ]
    struct Storage  {
        owner : ContractAddress, 
        admin : ContractAddress, 
        paused: bool, 
        values: L egacyMap <ContractAddress, u 256 >,
         total _supply: u256 ,
    } 

    #[event ]
    # [derive(Drop,  starknet::Event )]
    enum Event  {
        Value Set: ValueSet,
         Ownership Transferred: Ow nershipTransferred, 
        Pause d: Paused, 
        Unpa used: Unpa used,
    } 

    #[derive (Drop, stark net::Event)] 
    struct ValueSet { 
        account : ContractAddress, 
        previous _value: u256 ,
        new_ value: u256, 
        timestamp: u 64,
    } 

    #[derive (Drop, stark net::Event)] 
    struct Owner shipTransferred { 
        previous_owner: Contract Address,
        new _owner: Contract Address,
    } 

    #[derive (Drop, stark net::Event)] 
    struct Pause d {
        account:  ContractAddress, 
    }

    #[ derive(Drop, st arknet::Event)] 
    struct Un paused {
         account: ContractAddress ,
    } 

    mod Errors {
        const  INVALID_CALLER: felt 252 = ' Caller is  not authorized';
         const ZERO_ADDRESS: felt252  = 'Zero  address not allowed';
        const  CONTRACT_PAUSED:  felt252 =  'Contract is pause d';
        const  INVALID_VALUE: felt252  = 'Invali d value provided';
        const  OVERFLOW: felt252 =  'Arithmetic overflow ';
     }

    #[ constructor]
    fn constructor (ref self: Cont ractState,  owner: ContractAddress ) {
        assert (!owner .is_zero(),  Errors::ZERO _ADDRESS);
         self.owner. write(owner); 
        self.admin. write(owner); 
        self.pause d.write(false); 
        self.total _supply.write( 0); 
    }

     #[ abi(embed_v 0)]
    impl  SecureContract of  super::ISec ureContract<Cont ractState> { 
        fn get _value(self:  @ContractState,  account: ContractAddress ) -> u256  {
            assert(! account.is_zero (), Errors:: ZERO_ADDRESS); 
            self .values.read( account)
        } 

        fn set_ value(ref self:  ContractState, value : u256)  {
            self .assert_not _paused(); 
            let  caller = get_caller_ address();
            assert (!caller.is_zero (), Errors:: ZERO_ADDRESS);
             
            let previous _value = self. values.read(caller );
            self .values.write( caller, value); 

            // Update  total supply
            let  new_total  = self.total_ supply.read() -  previous_value + value ;
            assert (new_total >= value , Errors:: OVERFLOW);
            self .total_supply. write(new_total);

            self .emit( Event::ValueSet( 
                Value Set {
                     account: caller, 
                    previous_value ,
                    new _value: value, 
                    timestamp:  get_block_timestamp (),
                } 
            ));
         }

        fn transfer _ownership(ref self : ContractState,  new_owner: Cont ractAddress) { 
            self.assert_ only_owner ();
            assert (!new_owner. is_zero(),  Errors::ZERO_ ADDRESS);
             
            let previous _owner = self. owner.read(); 
            self.owner. write(new_owner );

            self.emit( Event::Owner shipTransferred( 
                Ownership Transferred {
                     previous_owner, 
                    new_ owner,
                } 
            )); 
        }

        fn  pause(ref self:  ContractState) { 
            self.assert _only_admin ();
            assert (!self.pause d.read(),  'Already  paused');
             self.paused. write(true); 
            
            self.emit( Event::Pause d(
                Paused { 
                    account:  get_caller_address ()
                }
             ));
        } 

        fn unpause (ref self: Cont ractState) { 
            self.assert_ only_admin(); 
            assert(self. paused.read(),  'Already unpaused'); 
            self.pause d.write(false); 

            self.emit( Event::Unpa used(
                 Unpaused { 
                    account: get _caller_address() 
                }
             ));
        } 
    }

    # [generate_trait ]
    impl  InternalFunctions of  InternalFunction sTrait {
        fn assert_ only_owner(self:  @ContractState) { 
            let caller = get_caller _address();
             assert(caller == self .owner.read(),  Errors::INVALID _CALLER); 
        }

        fn  assert_only_admin (self: @Cont ractState) { 
            let caller = get _caller_address();
            assert(caller  == self.admin.read(), Errors:: INVALID_CALLER );
        } 

        fn assert_not _paused(self : @ContractState ) {
            assert (!self.pause d.read(), Errors ::CONTRACT_PA USED);
        } 
    }
} 

#[starknet:: interface]
trait ISecureContract<T ContractState> { 
    fn get_value(self : @TContractState, account: Cont ractAddress) -> u 256;
    fn  set_value(ref  self: TContract State, value: u 256);
    fn  transfer_ownership(ref  self: TContract State, new_owner : ContractAddress); 
    fn pause( ref self: TCont ractState);
     fn unpause(ref  self: TContract State);
} 
```  