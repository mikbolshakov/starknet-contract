use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn balance_of(self: @TContractState, account: ContractAddress) -> felt252;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: felt252);
    fn transfer_from(
        ref self: TContractState, 
        sender: ContractAddress, 
        recipient: ContractAddress, 
        amount: felt252,
    );
}

#[starknet::interface]
pub trait ISimpleVault<TContractState> {
    fn deposit(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState);
    fn get_contract_balance(self: @TContractState) -> u256;
}

#[starknet::contract]
pub mod SimpleVault {
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        token: IERC20Dispatcher,
        total_balance: u256,
    }

    // #[event]
    // #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    // pub enum Event {
    //     Deposited: Deposited,
    //     Withdrawn: Withdrawn
    // }

    // #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    // pub struct Deposited {
    //     pub user: ContractAddress,
    //     pub amount: u256
    // }

    // #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    // pub struct Withdrawn {
    //     pub amount: u256
    // }

    #[constructor]
    fn constructor(ref self: ContractState, token: ContractAddress) {
        self.token.write(IERC20Dispatcher { contract_address: token });
        self.total_balance.write(0);
    }

    #[abi(embed_v0)]
    impl SimpleVault of super::ISimpleVault<ContractState> {
        fn get_contract_balance(self: @ContractState) -> u256 {
            self.total_balance.read()
        }

        fn deposit(ref self: ContractState, amount: u256) {
            assert(amount > 0, 'Can not deposit 0');
            let caller = get_caller_address();
            let this = get_contract_address();

            let current_balance: u256 = self.token.read().balance_of(this).try_into().unwrap();
            self.total_balance.write(current_balance + amount);

            let amount_felt252: felt252 = amount.low.into();
            self.token.read().transfer_from(caller, this, amount_felt252);

            // self.emit(Deposited { user: caller, amount });
        }

        fn withdraw(ref self: ContractState) {
            let caller: ContractAddress = 0x0000A7aEFbb60738b333Fa67d3C2316BeF69593fF3f420b8fb0bF2a7c47e9A11
                .try_into()
                .unwrap();
            let this = get_contract_address();

            let current_balance: u256 = self.token.read().balance_of(this).try_into().unwrap();

            let amount_felt252: felt252 = current_balance.low.into();
            self.token.read().transfer(caller, amount_felt252);

            self.total_balance.write(0);

            // self.emit(Withdrawn { amount: current_balance });
        }
    }
}
