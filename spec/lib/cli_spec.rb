# frozen_string_literal: true

RSpec.describe CLI do
  subject { CLI.new.run }

  before do
    # Stubbing out system('clear') prevents the clear_screen command in the CLI from messing with the rspec output
    allow_any_instance_of(Kernel).to receive(:system).with('clear').and_return(true)

    # This stubs us providing input to the CLI. By splatting the user_input array into the return variables
    # it will return each in turn, allowing us to simulate entering multiple commands.
    # Unfortunately since this is a full stub of gets we don't get to see the command in the output when
    # we check stdout.
    allow_any_instance_of(Kernel).to receive(:gets).and_return(*user_input)
  end

  let(:introduction) do
    "Welcome to Vending Machine\n" \
    "\n#{initial_stock_output}\n" \
    "#{initial_change_output}\n" \
    "#{options_output}\n" \
    '> '
  end

  let(:initial_stock_output) do
    "Current Stock\n" \
    "=============\n" \
    "Pepsi x 2 @ £0.50\n" \
    "Coke x 3 @ £0.60\n" \
    "Banana x 4 @ £0.30\n"
  end

  let(:initial_change_output) do
    "Current Change\n" \
    "==============\n" \
    "£2 x 5\n" \
    "£1 x 5\n" \
    "50p x 5\n" \
    "20p x 5\n" \
    "10p x 5\n" \
    "5p x 5\n" \
    "2p x 5\n" \
    "1p x 5\n"
  end

  let(:options_output) do
    "Available Options\n" \
    "=================\n" \
    "balance:      Output Balance\n" \
    "insert <x>:   Insert Coin (options: £2, £1, 50p, 20p, 10p, 5p, 2p, 1p)\n" \
    "stock:        Display current stock\n" \
    "change:       Display current change in machine\n" \
    "purchase <x>: Attempt to purchase a product (case sensitive)\n" \
    "reload <x>:   Reload vending machine back to initial values (options: products, change)\n" \
    "help:         Display these options\n" \
    "clear:        Clear history\n" \
    'exit:         Close CLI'
  end

  shared_examples_for 'correct output' do
    it 'functions correctly' do
      expect { subject }.to output(expected_output).to_stdout
    end
  end

  describe 'exit' do
    let(:user_input) { ['exit'] }

    let(:expected_output) { introduction }

    include_examples 'correct output'

    context 'with an option' do
      let(:user_input) { ['exit foo'] }

      include_examples 'correct output'
    end
  end

  describe 'invalid input' do
    let(:user_input) { %w[invalid exit] }

    let(:expected_output) do
      "#{introduction}ERROR: Invalid Input\n" \
      '> '
    end

    include_examples 'correct output'
  end

  describe 'help' do
    let(:user_input) { %w[help exit] }

    let(:expected_output) do
      "#{introduction}#{options_output}\n" \
      '> '
    end

    include_examples 'correct output'

    context 'with an option' do
      let(:user_input) { ['help foo', 'exit'] }

      include_examples 'correct output'
    end
  end

  describe 'clear' do
    let(:user_input) { %w[clear exit] }

    # This isn't a perfect test of what clear does.
    # system('clear') doesn't impact the output matcher and even if it did the specs
    # stub it to prevent it from messing with spec output.
    # This at least tests that it does not crash and will output the introduction again.
    let(:expected_output) do
      "#{introduction}#{introduction}"
    end

    include_examples 'correct output'

    context 'with an option' do
      let(:user_input) { ['clear foo', 'exit'] }

      include_examples 'correct output'
    end
  end

  describe 'balance' do
    let(:user_input) { %w[balance exit] }

    let(:expected_output) do
      "#{introduction}Current Balance: £0.00\n" \
      '> '
    end

    include_examples 'correct output'

    context 'with an option' do
      let(:user_input) { ['balance foo', 'exit'] }

      include_examples 'correct output'
    end
  end

  describe 'stock' do
    let(:user_input) { %w[stock exit] }

    let(:expected_output) do
      "#{introduction}#{initial_stock_output}" \
      '> '
    end

    include_examples 'correct output'

    context 'with an option' do
      let(:user_input) { ['stock foo', 'exit'] }

      include_examples 'correct output'
    end

    context 'when stock empty' do
      before do
        allow_any_instance_of(ConfigLoader).to receive(:initial_products).and_return([])
      end

      let(:initial_stock_output) do
        "Current Stock\n" \
        "=============\n" \
        "No products in stock\n"
      end

      include_examples 'correct output'
    end
  end

  describe 'change' do
    let(:user_input) { %w[change exit] }

    let(:expected_output) do
      "#{introduction}#{initial_change_output}" \
      '> '
    end

    include_examples 'correct output'

    context 'with an option' do
      let(:user_input) { ['change foo', 'exit'] }

      include_examples 'correct output'
    end

    context 'when change empty' do
      before do
        allow_any_instance_of(ConfigLoader).to receive(:initial_change).and_return([])
      end

      let(:initial_change_output) do
        "Current Change\n" \
        "==============\n" \
        "No change available\n"
      end

      include_examples 'correct output'
    end
  end

  describe 'insert' do
    let(:user_input) { ["insert #{coin_to_insert}".strip, 'exit'] }

    context 'with a valid coin' do
      let(:coin_to_insert) { '£1' }

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £1.00\n" \
        '> '
      end

      include_examples 'correct output'
    end

    context 'with an invalid coin' do
      let(:coin_to_insert) { '$1' }

      let(:expected_output) do
        "#{introduction}ERROR: Invalid argument $1\n" \
        '> '
      end

      include_examples 'correct output'
    end

    context 'with no coin' do
      let(:coin_to_insert) { nil }

      let(:expected_output) do
        "#{introduction}ERROR: Invalid argument \n" \
        '> '
      end

      include_examples 'correct output'
    end
  end

  describe 'purchase' do
    context 'for a product not in stock' do
      let(:user_input) do
        [
          'insert £1',
          'purchase Lettuce',
          'balance',
          'stock',
          'change',
          'exit'
        ]
      end

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £1.00\n" \
        "> ERROR: out_of_stock\n" \
        "> Current Balance: £1.00\n" \
        "> #{initial_stock_output}" \
        "> #{initial_change_output}" \
        '> '
      end

      include_examples 'correct output'
    end

    context 'without enough balance' do
      let(:user_input) do
        [
          'insert 10p',
          'purchase Banana',
          'balance',
          'stock',
          'change',
          'exit'
        ]
      end

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £0.10\n" \
        "> ERROR: insufficient_balance\n" \
        "> Current Balance: £0.10\n" \
        "> #{initial_stock_output}" \
        "> #{initial_change_output}" \
        '> '
      end

      include_examples 'correct output'
    end

    context 'without enough change in the machine' do
      before do
        allow_any_instance_of(ConfigLoader).to receive(:initial_change).and_return([])
      end

      let(:user_input) do
        [
          'insert £1',
          'purchase Banana',
          'balance',
          'stock',
          'change',
          'exit'
        ]
      end

      let(:initial_change_output) do
        "Current Change\n" \
        "==============\n" \
        "No change available\n"
      end

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £1.00\n" \
        "> ERROR: insufficient_change\n" \
        "> Current Balance: £1.00\n" \
        "> #{initial_stock_output}" \
        "> #{initial_change_output}" \
        '> '
      end

      include_examples 'correct output'
    end

    context 'with exact change' do
      let(:user_input) do
        [
          'insert 20p',
          'insert 10p',
          'purchase Banana',
          'balance',
          'stock',
          'change',
          'exit'
        ]
      end

      let(:new_stock) do
        "Current Stock\n" \
        "=============\n" \
        "Pepsi x 2 @ £0.50\n" \
        "Coke x 3 @ £0.60\n" \
        "Banana x 3 @ £0.30\n"
      end

      let(:new_change) do
        "Current Change\n" \
        "==============\n" \
        "£2 x 5\n" \
        "£1 x 5\n" \
        "50p x 5\n" \
        "20p x 6\n" \
        "10p x 6\n" \
        "5p x 5\n" \
        "2p x 5\n" \
        "1p x 5\n"
      end

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £0.20\n" \
        "> Coin Inserted\n" \
        "Current Balance: £0.30\n" \
        "> Banana vended\n" \
        "No change is dispensed\n" \
        "> Current Balance: £0.00\n" \
        "> #{new_stock}" \
        "> #{new_change}" \
        '> '
      end

      include_examples 'correct output'
    end

    context 'with excess money' do
      let(:user_input) do
        [
          'insert £1',
          'purchase Banana',
          'balance',
          'stock',
          'change',
          'exit'
        ]
      end

      let(:new_stock) do
        "Current Stock\n" \
        "=============\n" \
        "Pepsi x 2 @ £0.50\n" \
        "Coke x 3 @ £0.60\n" \
        "Banana x 3 @ £0.30\n"
      end

      let(:new_change) do
        "Current Change\n" \
        "==============\n" \
        "£2 x 5\n" \
        "£1 x 6\n" \
        "50p x 4\n" \
        "20p x 4\n" \
        "10p x 5\n" \
        "5p x 5\n" \
        "2p x 5\n" \
        "1p x 5\n"
      end

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £1.00\n" \
        "> Banana vended\n" \
        "£0.70 is dispensed\n" \
        "It consists of: 50p, 20p\n" \
        "> Current Balance: £0.00\n" \
        "> #{new_stock}" \
        "> #{new_change}" \
        '> '
      end

      include_examples 'correct output'
    end

    context 'with the product name in the wrong case' do
      let(:user_input) do
        [
          'insert £1',
          'purchase bANANA',
          'balance',
          'stock',
          'change',
          'exit'
        ]
      end

      let(:new_stock) do
        "Current Stock\n" \
        "=============\n" \
        "Pepsi x 2 @ £0.50\n" \
        "Coke x 3 @ £0.60\n" \
        "Banana x 3 @ £0.30\n"
      end

      let(:new_change) do
        "Current Change\n" \
        "==============\n" \
        "£2 x 5\n" \
        "£1 x 6\n" \
        "50p x 4\n" \
        "20p x 4\n" \
        "10p x 5\n" \
        "5p x 5\n" \
        "2p x 5\n" \
        "1p x 5\n"
      end

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £1.00\n" \
        "> Banana vended\n" \
        "£0.70 is dispensed\n" \
        "It consists of: 50p, 20p\n" \
        "> Current Balance: £0.00\n" \
        "> #{new_stock}" \
        "> #{new_change}" \
        '> '
      end

      include_examples 'correct output'
    end
  end

  describe 'reload' do
    context 'products' do
      let(:user_input) do
        [
          'insert £1',
          'purchase Banana',
          'stock',
          'change',
          'reload products',
          'stock',
          'change',
          'exit'
        ]
      end

      let(:new_stock) do
        "Current Stock\n" \
        "=============\n" \
        "Pepsi x 2 @ £0.50\n" \
        "Coke x 3 @ £0.60\n" \
        "Banana x 3 @ £0.30\n"
      end

      let(:new_change) do
        "Current Change\n" \
        "==============\n" \
        "£2 x 5\n" \
        "£1 x 6\n" \
        "50p x 4\n" \
        "20p x 4\n" \
        "10p x 5\n" \
        "5p x 5\n" \
        "2p x 5\n" \
        "1p x 5\n"
      end

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £1.00\n" \
        "> Banana vended\n" \
        "£0.70 is dispensed\n" \
        "It consists of: 50p, 20p\n" \
        "> #{new_stock}" \
        "> #{new_change}" \
        "> Products reloaded back to initial contents\n" \
        "> #{initial_stock_output}" \
        "> #{new_change}" \
        '> '
      end

      include_examples 'correct output'
    end

    context 'change' do
      let(:user_input) do
        [
          'insert £1',
          'purchase Banana',
          'stock',
          'change',
          'reload change',
          'stock',
          'change',
          'exit'
        ]
      end

      let(:new_stock) do
        "Current Stock\n" \
        "=============\n" \
        "Pepsi x 2 @ £0.50\n" \
        "Coke x 3 @ £0.60\n" \
        "Banana x 3 @ £0.30\n"
      end

      let(:new_change) do
        "Current Change\n" \
        "==============\n" \
        "£2 x 5\n" \
        "£1 x 6\n" \
        "50p x 4\n" \
        "20p x 4\n" \
        "10p x 5\n" \
        "5p x 5\n" \
        "2p x 5\n" \
        "1p x 5\n"
      end

      let(:expected_output) do
        "#{introduction}Coin Inserted\n" \
        "Current Balance: £1.00\n" \
        "> Banana vended\n" \
        "£0.70 is dispensed\n" \
        "It consists of: 50p, 20p\n" \
        "> #{new_stock}" \
        "> #{new_change}" \
        "> Change reloaded back to initial contents\n" \
        "> #{new_stock}" \
        "> #{initial_change_output}" \
        '> '
      end

      include_examples 'correct output'
    end
  end
end
