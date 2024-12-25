use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
pub trait ISimpleVault<TContractState> {
    fn get_contract_balance(self: @TContractState) -> u256;
    fn deposit(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState);
}

#[starknet::contract]
pub mod SimpleVault {
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};

    #[storage]
    struct Storage {
        token: IERC20Dispatcher,
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

            let current_balance = self.total_balance.read();
            self.total_balance.write(current_balance + amount);

            self.token.read().transfer_from(caller, this, amount);

            self.emit(Deposited { user: caller, amount });
        }

        fn withdraw(ref self: ContractState) {
            let caller: ContractAddress = 0x040048a1fe47e0a948bab169712d1736c3e18e087911a708a1634f605dd50c38
                .try_into()
                .unwrap();
            let this = get_contract_address();
        
            let current_balance = self.total_balance.read();
        
            self.token.read().transfer(caller, current_balance);
        
            self.total_balance.write(0);
        
            self.emit(Withdrawn { amount: current_balance });
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{SimpleVault, ISimpleVaultDispatcher, ISimpleVaultDispatcherTrait};
    use erc20::token::{
        IERC20DispatcherTrait as IERC20DispatcherTrait_token,
        IERC20Dispatcher as IERC20Dispatcher_token,
    };
    use starknet::testing::{set_contract_address, set_account_contract_address};
    use starknet::{ContractAddress, syscalls::deploy_syscall, contract_address_const};

    const token_name: felt252 = 'myToken';
    const decimals: u8 = 18;
    const initial_supply: felt252 = 100000;
    const symbols: felt252 = 'mtk';

    fn deploy() -> (ISimpleVaultDispatcher, ContractAddress, IERC20Dispatcher_token) {
        let _token_address: ContractAddress = contract_address_const::<'token_address'>();
        let caller = contract_address_const::<'caller'>();

        let (token_contract_address, _) = deploy_syscall(
            erc20::token::erc20::TEST_CLASS_HASH.try_into().unwrap(),
            caller.into(),
            array![caller.into(), token_name, decimals.into(), initial_supply, symbols].span(),
            false,
        )
            .expect('1');

        let (contract_address, _) = deploy_syscall(
            SimpleVault::TEST_CLASS_HASH.try_into().unwrap(),
            0,
            array![token_contract_address.into()].span(),
            false,
        )
            .expect('2');

        (
            ISimpleVaultDispatcher { contract_address },
            contract_address,
            IERC20Dispatcher_token { contract_address: token_contract_address },
        )
    }

    #[test]
    fn test_deposit() {
        let caller = contract_address_const::<'caller'>();
        let (dispatcher, vault_address, token_dispatcher) = deploy();

        // Approve the vault to transfer tokens on behalf of the caller
        let amount: felt252 = 10.into();
        token_dispatcher.approve(vault_address.into(), amount);
        set_contract_address(caller);

        // Deposit tokens into the vault
        let amount: u256 = 10.into();
        let _deposit = dispatcher.deposit(amount);
        println!("deposit :{:?}", _deposit);

        let total_supply = dispatcher.get_contract_balance();

        assert_eq!(total_supply, amount);
    }
}

