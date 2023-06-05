use cairol::C3::C3;
use cairol::BalanceChecker::BalanceChecker as BC;
use cairol::BalanceStorer::BalanceStorer as BS;

use debug::PrintTrait;
use integer::u256_from_felt252;

use starknet::ContractAddress;
use starknet::get_contract_address;
use starknet::get_caller_address;
use starknet::syscalls::deploy_syscall;
use starknet::contract_address_const;
use starknet::contract_address_to_felt252;

use starknet::testing::set_contract_address;
use starknet::testing::set_caller_address;

// Integration tests, where contract interaction can be tested.

#[test]
#[available_gas(2000000)]
fn checker_balance_of() {
    // We need the class hash anyway + serialize arguments.
    // deploy_syscall();

    //let storer_addr = BS::get_contract_address_me();
    let storer_addr = contract_address_const::<1234>();
    // Consider being the storer executing.
    // set_contract_address(storer_addr);

    let storer_admin_addr: ContractAddress = contract_address_const::<155>();

    //BS::set_contract_address_me(storer_addr);

    // set_contract_address defines in which storage we are writting into.
    set_contract_address(storer_addr);
    BS::constructor(storer_admin_addr);

    // This seems to now be working, we have an address, but it's not known in
    // the current context.

    let dest_addr: ContractAddress = contract_address_const::<888>();
    let new_balance: u256 = u256_from_felt252(122334);

    // We simulate here that we are the admin storer, which means
    // that in BS::balance_set, we match the `get_caller_address`.

    set_caller_address(storer_admin_addr);
    BS::balance_set(dest_addr, new_balance);

    // Now.. how to reuse a "deployed" contract -> devnet.
    //BS::set_contract_address_me(storer_addr);

    let checker_addr = contract_address_const::<22222>();
    set_contract_address(checker_addr);
    BC::constructor(storer_addr);

    // Seems that the storage used is not the correct one...
    let b = BC::balance_of(dest_addr);
    assert(b == new_balance, 'balance fail');

    // TODO: test with a third contract calling this one...!
    set_contract_address(contract_address_const::<33333>());
    C3::constructor(checker_addr);
    let c = C3::balance_of(dest_addr);
    assert(c == new_balance, 'balance fail');
}

// #[test]
// #[available_gas(2000000)]
// fn checker_balance_of2() {
//     let storer_admin_addr: ContractAddress = contract_address_const::<1>();
//     BS::constructor(storer_admin_addr);

//     //let storer_addr = BS::get_contract_address_me();
//     let storer_addr = contract_address_const::<9999>();
//     // BS::set_contract_address_me(storer_addr);

//     // This seems to now be working, we have an address, but it's not known in
//     // the current context.

//     let dest_addr: ContractAddress = contract_address_const::<888>();
//     let new_balance: u256 = u256_from_felt252(873);

//     // We simulate here that we are the admin storer, which means
//     // that in BS::balance_set, we match the `get_caller_address`.

//     //set_contract_address(contract_address_const::<2>());
//     //set_caller_address(contract_address_const::<2>());

//     set_caller_address(storer_admin_addr);

//     BS::balance_set(dest_addr, new_balance);

//     // Now.. how to reuse a "deployed" contract -> devnet.
//     BC::constructor(storer_addr);

//     // let checker_addr = contract_address_const::<1234567>();
//     // BC::set_contract_address_me(checker_addr);

//     // let b = BC::balance_of(dest_addr);
//     // assert(b == new_balance, 'balance fail');
// }
