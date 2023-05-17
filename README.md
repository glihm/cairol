# Cairol : Cairo 1 Lab

This repo is still very experimental. The idea is to have, in one place, Cairo 1 testing resources.
This is inspired from Starknet basecamps #4 I am going through.

`scarb run test-docker`

## Config

The current configuration is targetting Cairo 1.0.0, using the docker image to run tests.
You can find the command in the `Scarb.toml`, in the script section.

For now, the modules are not always very separated, but a refacto may be done later during
the progress.

## Consideration

The current features of `cairo-test` is not allowing to call contracts using the
`#[abi]` generated code. This mean, you can test almost any logic in Cairo inside a
contract, but you can't interact with other contracts by calling them from their address:

`IBalanceStorerDispatcher { contract_address: storer_addr::read() }.balance_of(addr)`

This will output an error with `CONTRACT_NOT_DEPLOYED`.

In fact, any call using this syntax is already the `network` responsability. Which then
redirect you to use a `devnet` first to run your integration tests.

## Mocking

As contracts are no more than Cairo module, we can then think about how mocking
would be achieve using the current `cairo-test` capabilities.

The first implication is that, the mocking without interacting with a `devnet` will involve
duplicating code, to reimplement the mocked version of any contract function that contains
a call to an other contract.

I am not sure yet of the possible value of doing this, but it makes me think twice.
Because this can also allow us to achieve a fairly good testing to verify that the
logic coded in Cairo is valid, taking in account several contracts interaction.

Taking an example of a very common case: ERC20 contract.
If one contract we are developping wants to interact with this contract, without being
in a `devnet`, we can't call the contract methods using something like (let's say the ERC20
contract address is present in the Storage of our contract):  

`IERC20Dispatcher { contract_address: erc20_address::read() }.balance_of(account_address)`.

But in integration testing, we care about evaluating the different values that can be returned
by this other contract. And that's why mocking a contract is so interesting, even in local,
without the complexity of a `network`.

Work in progress...
