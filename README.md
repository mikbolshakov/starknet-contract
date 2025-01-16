# Smart contract deployment instructions

##### \*Two options: **starkli** and **sncast\***

##### \*Suitable for both: **mainnet** and **testnet\***

##### _Suitable for **standard** (not smart) accounts from **Argent** Wallet_

address: 0x07F37a268684CE74dBeD7096dC32c64A471F2F1F7e47C09bB8749765199e0199
private key: 0x05ce6ec61ed019d65ac1216bc6a92f62202dc78002d0c0163d545df9489e562b

## starkli

##### keystore.json

Create a new encrypted keystore signer

```bash
starkli signer keystore from-key ~/.starkli-wallets/deployer/keystore.json
```

##### account.json

Create a new account

```bash
starkli account fetch 0x07F37a268684CE74dBeD7096dC32c64A471F2F1F7e47C09bB8749765199e0199 --output ~/.starkli-wallets/deployer/account.json --rpc https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_7/Ua6UIZkJ1gNmt3
```

##### Wallet deploy

Deploy your account

```bash
starkli account deploy ~/.starkli-wallets/deployer/account.json --keystore ~/.starkli-wallets/deployer/keystore.json --rpc https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_7/Ua6UIZkJ1gNmt3
```

##### Contract class declare

Declare a contract

```bash
starkli declare --account ~/.starkli-wallets/deployer/account.json --keystore ~/.starkli-wallets/deployer/keystore.json --rpc https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_7/Ua6UIZkJ1gNmt3 target/dev/argent_contracts_Vault.contract_class.json
```

##### Contract deploy

Deploy contract to starknet

```bash
starkli deploy --account ~/.starkli-wallets/deployer/account.json --keystore ~/.starkli-wallets/deployer/keystore.json --rpc https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_7/Ua6UIZkJ1gNmt3 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d 0x02c6a256c84be90860c299e17721e47fcb0ff3699e09002a03e141aeb0a34869 2000000000000000000 0
```

where:

- 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d - token (STRK) address
- 0x02c6a256c84be90860c299e17721e47fcb0ff3699e09002a03e141aeb0a34869 - admin address
- 2000000000000000000 0 - deposit amount (2 STRK), both low (2000000000000000000) and high (0) must be specified

## sncast

##### Import the deployed wallet

Import already created and deployed wallet

```bash
sncast account import --url https://starknet-mainnet.g.alchemy.com/starknet/version/rpc/v0_7/Ua6UIZkJ1gNmt3 --name account_argent --address 0x07F37a268684CE74dBeD7096dC32c64A471F2F1F7e47C09bB8749765199e0199 --private-key 0x05ce6ec61ed019d65ac1216bc6a92f62202dc78002d0c0163d545df9489e562b --type argent
```

##### Contract class declare

Declare a contract to get a hash class

```bash
sncast --account account_argent declare --url https://starknet-mainnet.g.alchemy.com/starknet/version/rpc/v0_7/Ua6UIZkJ1gNmt3 --fee-token strk --contract-name Vault
```

##### Contract deploy

Deploy contract to starknet by its class hash

```bash
sncast --account account_argent deploy --url https://starknet-mainnet.g.alchemy.com/starknet/version/rpc/v0_7/Ua6UIZkJ1gNmt3 --fee-token strk --class-hash 0x00be86b635129463ea6065a9de7b45cf1cf6af2aabe4f6dc64c50b2a563aedd6 --constructor-calldata 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d 0x02c6a256c84be90860c299e17721e47fcb0ff3699e09002a03e141aeb0a34869 2000000000000000000 0
```
