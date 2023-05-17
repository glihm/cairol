// ** C1 **
//
// A very simple contract to test some basics about cairo contracts.
//

#[contract]
mod C1 {

    const FORBIDDEN_U8: u8 = 10_u8;

    struct Storage {
        name: felt252,
        val: u8,
    }

    #[constructor]
    fn constructor(
        name_: felt252,
        val_: u8,
    ) {
        name::write(name_);
        val::write(val_);
    }

    // Gets name.
    #[view]
    fn name_get() -> felt252 {
        name::read()
    }

    // Gets val.
    #[view]
    fn val_get() -> u8 {
        val::read()
    }

    // Sets val to the given v.
    // To test the should panic, we establish
    // that val can't be set to FORBIDDEN_U8.
    fn val_set(v: u8) {
        assert(v != FORBIDDEN_U8, 'forbidden value');
        val::write(v);
    }

}

#[cfg(test)]
mod tests{

    use debug::PrintTrait; 
    use super::C1;

    const FORBIDDEN_U8: u8 = 10_u8;

    #[test]
    #[available_gas(2000000)]
    fn test_c1_ctor() {
        let name: felt252 = 'glihm';
        let val: u8 = 42;

        C1::constructor(name, val);

        let n = C1::name_get();
        assert(n == name, 'name fail');

        let v = C1::val_get();
        assert(v == val, 'val fail');
    }

    #[test]
    #[available_gas(2000000)]
    fn test_val_set() {
        // Each test has its own instance fo C1.
        // Must be init (if needed) in each test.
        C1::constructor('glihm', 87);

        let v = C1::val_get();
        assert(v == 87, 'ctor fail');

        // Interesting to see that we can test internal functions, even from
        // an other module.
        C1::val_set(12);
        assert(C1::val_get() == 12, 'val_set fail');
    }

    #[test]
    #[should_panic()]
    #[available_gas(2000000)]
    fn test_val_set_forbidden() {
        C1::val_set(FORBIDDEN_U8);
    }
}
