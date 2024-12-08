#[starknet::contract]
mod contractww {
    #[storage]
    struct Storage {}

    #[external(v0)]
    fn hello(self: @ContractState) -> felt252 {
        'Hello WAARLD'
    }
}