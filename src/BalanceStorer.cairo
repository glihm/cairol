// ** BalanceStorer **
//
// A contract to store a balance, associated to a contract address.
// The balance of contracts can only be edited by a "administrator" contract.
//

#[contract]
mod BalanceStorer {

    use starknet::contract_address_const;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::ContractAddress;
    use starknet::testing::set_contract_address;

    struct Storage {
        admin_addr: ContractAddress,
        balances: LegacyMap::<ContractAddress, u256>,
    }

    #[constructor]
    fn constructor(
        admin_addr_: ContractAddress,
    ) {
        admin_addr::write(admin_addr_);
    }

    // Gets balance of given contract address.
    #[view]
    fn balance_of(addr: ContractAddress) -> u256 {
        balances::read(addr)
    }

    // Sets balance of given contract addr.
    fn balance_set(addr: ContractAddress, v: u256) {
        assert(get_caller_address() == admin_addr::read(), 'unauthorized');
        balances::write(addr, v);
    }

    #[view]
    fn get_contract_address_me() -> ContractAddress {
        set_contract_address(contract_address_const::<8777>());
        get_contract_address()
    }

}

#[cfg(test)]
mod tests {

    use super::BalanceStorer as BS;
    use debug::PrintTrait;
    use integer::u256_from_felt252;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;

    #[test]
    #[available_gas(2000000)]
    fn init() {
        let admin_addr: ContractAddress = contract_address_const::<1>();
        BS::constructor(admin_addr);

        // There is no difference between a balance set to 0 and
        // a query made for an addr that is not present in the LegacyMap.
        // Both return 0.
        let b = BS::balance_of(admin_addr);
        assert(b == u256_from_felt252(0), 'balance fail');
    }

    #[test]
    #[available_gas(2000000)]
    fn balance_set() {
        let admin_addr: ContractAddress = contract_address_const::<1>();
        BS::constructor(admin_addr);

        let dest_addr: ContractAddress = contract_address_const::<2>();

        set_caller_address(admin_addr);

        let new_balance: u256 = u256_from_felt252(123);
        BS::balance_set(dest_addr, new_balance);

        assert(BS::balance_of(dest_addr) == new_balance, 'balance fail');
    }

    #[test]
    #[should_panic()]
    #[available_gas(2000000)]
    fn balance_set_bad_admin() {
        let admin_addr: ContractAddress = contract_address_const::<1>();
        BS::constructor(admin_addr);

        let dest_addr: ContractAddress = contract_address_const::<2>();
        let fake_admin_addr: ContractAddress = contract_address_const::<6>();

        set_caller_address(fake_admin_addr);

        let new_balance: u256 = u256_from_felt252(123);
        let b = BS::balance_set(dest_addr, new_balance);
    }


}
