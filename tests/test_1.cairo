use cairol::BalanceChecker::BalanceChecker as BC;
use cairol::BalanceStorer::BalanceStorer as BS;

use debug::PrintTrait;
use integer::u256_from_felt252;

use starknet::ContractAddress;
use starknet::get_contract_address;
use starknet::contract_address_const;
use starknet::contract_address_to_felt252;

use starknet::testing::set_contract_address;
use starknet::testing::set_caller_address;

// Integration tests, where contract interaction can be tested.

#[test]
#[available_gas(2000000)]
fn checker_balance_of() {
    let storer_admin_addr: ContractAddress = contract_address_const::<1>();    

    BS::constructor(storer_admin_addr);
    let storer_addr = BS::get_contract_address_me();
    // This seems to now be working, we have an address, but it's not known in
    // the current context.

    let dest_addr: ContractAddress = contract_address_const::<888>();    
    let new_balance: u256 = u256_from_felt252(123);

    // We simulate here that we are the admin storer, which means
    // that in BS::balance_set, we match the `get_caller_address`.
    set_contract_address(storer_addr);
    BS::balance_set(dest_addr, new_balance);

    // Now.. how to reuse a "deployed" contract -> devnet.
    // BC::constructor(storer_addr);

    // let b = BC::balance_of(dest_addr);
    // assert(b == new_balance, 'balance fail');
}
