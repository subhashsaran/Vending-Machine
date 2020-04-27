# Cleo Tech Test

## How to Use

First off, you'll need to ensure you have ruby 2.6.3 installed as this is the version the project's Gemfile specifies. Once you have that installed the final prep required is `bundle`. After that you can boot up the CLI by running `ruby main.rb`. You will then be presented with this interface:

```
Welcome to Vending Machine

Current Stock
=============
...stock...

Current Change
==============
...change...

Available Options
=================
balance:      Output Balance
insert <x>:   Insert Coin (options: £2, £1, 50p, 20p, 10p, 5p, 2p, 1p)
stock:        Display current stock
change:       Display current change in machine
purchase <x>: Attempt to purchase a product (case sensitive)
reload <x>:   Reload vending machine back to initial values (options: products, change)
help:         Display these options
clear:        Clear history
exit:         Close CLI
>
```

From here you can enter any of the given inputs to perform an action.

### insert <x>
Follows the format `insert £1`, `insert 50p`. Other inputs will be rejected.

### purchase <x>
Follows the format `purchase Pepsi`. This is case sensitive so entering `purchase pepsi` will return an out_of_stock error.

### reload <x>
Follows the format `reload change` and `reload products`. This will reset the stock/change lists to their original values.

ConfigLoader does not cache `initial.json`, if you want to adjust the change or products in the vending machine for a running instance of the CLI you can edit this file and then run the reload command. This will reparse the file and load it into the vending machine.

## How to Test

There are two ways to use the system, either via the included CLI as described above or by loading up a rails console and loading the lib directory to manually interact with the VendingMachine, Coin, and Product interfaces.

In terms of exploring the code a nice way to explore is to begin with the more simple components, the Coin and Product classes. These are the basic building blocks of the system as they make up the main things that are passed back and forth with the VendingMachine.

From there the VendingMachine's public interface allows you to explore the interactions within the system.

There are further comments within each class and the commit history contains relevant information regarding implementation at each step along the way so using `git blame` to see the commit that added a given line will provide useful information in the commit descriptions.

## Time Taken

I went with *Option 2* as described in the email, a more open ended set of time to implement the system. I started working on this at probably around 2:30pm-2:45pm, initially planning and writing up assumptions/requirements. I worked on it through till about 9pm (with breaks for food etc.), a fair while however I found it quite an interesting problem and I really enjoyed implementing a solution. Came back at just after 10pm to review, make some minor adjustments, and add docoumentation.

### What I'd do with extra time

- Break the various actions within the CLI out into their own classes. The CLI is an area of the code-base that would be nice to go back over and provide a neater solution for. Each of the actions could be broken into something along the lines of CLI::DisplayBalance which provides a command, description, and an action. That could move large amounts of the code within the CLI out into separate smaller classes.
- Add specs for the ConfigLoader. It is largely tested indirectly via the CLI specs but it would be nice to have dedicated specs around that.
- Update the reloading and initial loading system to optionally take user input, only falling back to the config file if the user chooses to user the defaults.
- Play with the UI some more, the initial interface displaying the Stock, Change, and Options is very long. It would be neat to look into better ways to display the data.
- Fix the case sensitive purchase command. It'd be more usable if you did not have to pay attention to the case of the product name when ordering.

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
- View Balance
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
