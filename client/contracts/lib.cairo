  ```rust 
use starknet::Cont ractAddress; 

#[starknet::interface ]
trait  IContract<TCont ractState> {
    fn  initialize(ref self : TContractState, owner : ContractAddress); 
    fn set_ admin(ref self: T ContractState, new _admin: Contract Address);
    fn  get_admin(self : @TContractState) ->  ContractAddress; 
}

#[stark net::contract] 
mod contract {
     use super::ContractAddress;
     use starknet: :{get_caller_ address, contract_address_ const};

    #[ event]
    # [derive(Drop , starknet::Event )]
    enum Event {
        Admin Changed: AdminChanged,
         Initialized: Initialized, 
    }

     #[derive(Drop, stark net::Event)]
    struct Admin Changed {
        previous _admin: Contract Address,
        new _admin: Contract Address,
    } 

    #[derive (Drop, stark net::Event)] 
    struct Initialized { 
        admin: Cont ractAddress
    }

    # [storage]
    struct Storage  {
        initialize d: bool,
         admin: ContractAddress ,
    } 

    #[constructor] 
    fn constructor( ref self: Cont ractState) {
        self .initialized.write(false );
        self. admin.write(contract _address_const: :<0>());
    } 

    #[generate _trait]
    impl Internal  of InternalTrait { 
        fn assert_only _admin(self:  @ContractState) { 
            let caller = get _caller_address(); 
            assert(caller == self. admin.read(),  'Caller is not admin ');
        } 

        fn assert_not _initialized(self: @ContractState)  {
            assert(!self.initialized.rea d(), 'Already initialized');
        } 

        fn assert_ valid_address(address: Contract Address) {
             assert(!address.is_zero (), 'Invalid address');
        } 
    }

    # [external(v 0)]
    impl  Contract of super::IContract<Cont ractState> { 
        fn initialize(ref self: ContractState , owner: Contract Address) {
             self.assert_not_initialized();
             Internal::assert_vali d_address(owner); 

            self.initialized.write( true);
            self .admin.write( owner);

            self.emit(Event:: Initialized(Initialized { admin: owner  }));
        }

        fn set_ admin(ref self: ContractState, new _admin: ContractAddress) {
             self.assert_only_admin();
             Internal::assert_vali d_address(new_ admin);

            let  previous_admin = self.admin.read(); 
            self.admin .write(new_ admin);

            self .emit(Event::AdminChanged( 
                AdminChanged { previous_admin, new _admin }
             ));
        } 

        fn get_ admin(self: @ContractState) ->  ContractAddress { 
            self.admin. read()
        } 
    }
}
```  