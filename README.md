# Cleo Tech Test

## How to Use

*Todo*

## How to Test

*Todo*

## Requirements

### Provided Info

Design a vending machine that behaves as follows:
- Once an item is selected and the appropriate amount of money is inserted, the vending machine should return the correct product
- It should also return change if too much money is provided, or ask for more money if insufficient funds have been inserted
- The machine should take an initial load of products and change. The change will be of denominations 1p, 2p, 5p, 10p, 20p, 50p, £1, £2
- There should be a way of reloading either products or change at a later point
- The machine should keep track of the products and change that it contains

As well as the functional requirements on the previous slide we also want your solution to:
- Be written in ruby
- Have tests
- Include a readme - think of it like the description you write on a github PR. Consider: explaining any decisions you made, telling us how to run it if it’s not obvious, signposting the best entry point for reviewing it, etc...
The bulk of our score comes from how you completed these functional and non-functional requirements. We also evaluate:
- How idiomatic your ruby code is
- The OO design of your classes and methods
- The simplicity of your solution

## Interface Functions To Implement

- View Products
- Insert Coin
- Purchase Product
- Reload Products
- Reload Change

### Extra functions

- Return Inserted Coins

## Assumptions Made

### Built with a CLI for interacting with the system

The core of the system will be a VendingMachine class that accepts Coins and Products, however to actually use those classes and see them in action we need an interface. A simple way to implement this is a CLI that will allow you to choose actions that interact with the vending machine.

### Attempting to insert a coin or purchase a product are not linked behaviours

This means that attempting to purchase a product does not lead to a flow where the machine starts asking for coins. The two are unlinked behaviours. This allows the machine to be stateless with regards to actions, it only needs to track products and the coins currently inside it. The UI also does not need to track the current state of the interface, just present options.

### Initial Products/Change Loaded via Config File

The requirements state that the vending machine should take an initial load of products and change. There are alternative ways to implement this, for example providing the user with an interface to enter new products, quantities, and prices. However this would add a fair bit of complexity onto the task so this will be left for a post-implementation addition if there is time.

### Reloading Products/Change means resetting the VendingMachine to its default

The requirements also state that "there should be a way of reloading either products or change at a later point". I have taken this to mean that there should be a command within the interface for resetting the products or change back to their initial state. This will be an option within the CLI which will empty and then restock the VendingMachine with its default for the option selected.

### If the machine cannot provide change it will return an error and prevent purchase

It is possible to have enough coins entered into the machine without enough change in the machine to refund the user. Rather than short changing the user or returning too much change the machine will instead return an 'insufficient change' error, preventing purchase.
