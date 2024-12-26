// #[cfg(test)]
// mod tests {
//     use super::{SimpleVault, ISimpleVaultDispatcher, ISimpleVaultDispatcherTrait};
//     use erc20::token::{
//         IERC20DispatcherTrait as IERC20DispatcherTrait_token,
//         IERC20Dispatcher as IERC20Dispatcher_token,
//     };
//     use starknet::testing::{set_contract_address};
//     use starknet::{ContractAddress, syscalls::deploy_syscall, contract_address_const};

//     const token_name: felt252 = 'myToken';
//     const decimals: u8 = 18;
//     const initial_supply: felt252 = 100000;
//     const symbols: felt252 = 'mtk';

//     fn deploy() -> (ISimpleVaultDispatcher, ContractAddress, IERC20Dispatcher_token) {
//         let _token_address: ContractAddress = contract_address_const::<'token_address'>();
//         let caller = contract_address_const::<'caller'>();

//         let (token_contract_address, _) = deploy_syscall(
//             erc20::token::erc20::TEST_CLASS_HASH.try_into().unwrap(),
//             caller.into(),
//             array![caller.into(), token_name, decimals.into(), initial_supply, symbols].span(),
//             false,
//         )
//             .expect('1');

//         let (contract_address, _) = deploy_syscall(
//             SimpleVault::TEST_CLASS_HASH.try_into().unwrap(),
//             0,
//             array![token_contract_address.into()].span(),
//             false,
//         )
//             .expect('2');

//         (
//             ISimpleVaultDispatcher { contract_address },
//             contract_address,
//             IERC20Dispatcher_token { contract_address: token_contract_address },
//         )
//     }

//     #[test]
//     fn test_deposit() {
//         let caller = contract_address_const::<'caller'>();
//         let (dispatcher, vault_address, token_dispatcher) = deploy();

//         // Approve the vault to transfer tokens on behalf of the caller
//         let amount: felt252 = 10.into();
//         token_dispatcher.approve(vault_address.into(), amount);
//         set_contract_address(caller);

//         // Deposit tokens into the vault
//         let amount: u256 = 10.into();
//         let _deposit = dispatcher.deposit(amount);
//         println!("deposit :{:?}", _deposit);

//         let total_supply = dispatcher.get_contract_balance();

//         assert_eq!(total_supply, amount);
//     }
// }

