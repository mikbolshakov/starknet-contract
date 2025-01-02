#[starknet::interface]
pub trait IVault<TContractState> {
    fn deposit(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState);
    fn get_contract_balance(self: @TContractState) -> u256;
}

#[starknet::contract]
pub mod Vault {
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        token: IERC20Dispatcher,
        admin: ContractAddress,
        total_balance: u256,
    }

    #[event]
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        Deposited: Deposited,
        Withdrawn: Withdrawn
    }

    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Deposited {
        pub user: ContractAddress,
        pub amount: u256
    }

    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Withdrawn {
        pub amount: u256
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        token: ContractAddress,
        admin: ContractAddress,
    ) {
        self.token.write(IERC20Dispatcher { contract_address: token });
        self.admin.write(admin);
    }

    #[abi(embed_v0)]
    impl Vault of super::IVault<ContractState> {
        fn get_contract_balance(self: @ContractState) -> u256 {
            self.total_balance.read()
        }

        fn deposit(ref self: ContractState, amount: u256) {
            assert(amount != 0, 'Amount cannot be 0');

            let caller = get_caller_address();
            let this = get_contract_address();

            self.total_balance.write(self.total_balance.read() + amount);

            self.token.read().transfer_from(caller, this, amount);

            self.emit(Deposited { user: caller, amount });
        }

        fn withdraw(ref self: ContractState) {
            let current_balance = self.total_balance.read();

            assert(get_caller_address() == self.admin.read(), 'You are not an admin');
            assert(current_balance != 0, 'Contract balance is zero');

            self.token.read().transfer(self.admin.read(), current_balance);
            self.total_balance.write(0);

            self.emit(Withdrawn { amount: current_balance });
        }
    }
}
