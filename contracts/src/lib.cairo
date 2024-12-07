#[starknet::contract]
mod contract {
    #[storage]
    struct Storage {}

    #[external(v0)]
    fn hello(self: @ContractState) -> felt252 {
        'Hello World'
    }
}