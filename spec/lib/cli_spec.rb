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
    "Banana x 4 @ £0.30\n" \
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
    "balance:    Output Balance\n" \
    "insert <x>: Insert Coin (options: £2, £1, 50p, 20p, 10p, 5p, 2p, 1p)\n" \
    "stock:      Display current stock\n" \
    "change:     Display current change in machine\n" \
    "help:       Display these options\n" \
    "clear:      Clear history\n" \
    'exit:       Close CLI' \
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
end
