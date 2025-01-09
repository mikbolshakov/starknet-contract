#[starknet::interface]
pub trait IVault<TContractState> {
    fn deposit(ref self: TContractState);
    fn withdraw(ref self: TContractState);
    fn set_deposit_amount(ref self: TContractState, amount: u256);
    fn get_deposit_amount(self: @TContractState) -> u256;
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
        deposit_amount: u256,
    }

    #[event]
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        Changed: Changed,
        Deposited: Deposited,
        Withdrawn: Withdrawn
    }

    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Changed {
        pub new_amount: u256
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
        amount: u256,
    ) {
        self.token.write(IERC20Dispatcher { contract_address: token });
        self.admin.write(admin);
        self.deposit_amount.write(amount);
    }

    #[abi(embed_v0)]
    impl Vault of super::IVault<ContractState> {
        fn get_contract_balance(self: @ContractState) -> u256 {
            self.token.read().balance_of(get_contract_address())
        }

        fn get_deposit_amount(self: @ContractState) -> u256 {
            self.deposit_amount.read()
        }

        fn set_deposit_amount(ref self: ContractState, amount: u256) {
            assert(get_caller_address() == self.admin.read(), 'You are not an admin');

            self.deposit_amount.write(amount);

            self.emit(Changed { new_amount: amount });
        }

        fn deposit(ref self: ContractState) {
            let caller = get_caller_address();
            let this = get_contract_address();
            let amount = self.deposit_amount.read();

            self.token.read().transfer_from(caller, this, amount);

            self.emit(Deposited { user: caller, amount });
        }

        fn withdraw(ref self: ContractState) {
            assert(get_caller_address() == self.admin.read(), 'You are not an admin');

            let current_balance = self.token.read().balance_of(get_contract_address());

            assert(current_balance != 0, 'Contract balance is zero');

            self.token.read().transfer(self.admin.read(), current_balance);

            self.emit(Withdrawn { amount: current_balance });
        }
    }
}
