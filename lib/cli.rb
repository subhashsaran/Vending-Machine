# frozen_string_literal: true

Dir[File.join(__dir__, '**', '*.rb')].sort.each { |file| require file }
require 'money'
I18n.enforce_available_locales = false
Money.locale_backend = nil
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

class CLI
  def initialize
    initial_config = ConfigLoader.new

    @vending_machine = VendingMachine.new(
      products: initial_config.initial_products,
      change: initial_config.initial_change
    )
  end

  BALANCE_OPTION     = 'balance'
  INSERT_COIN_OPTION = 'insert'
  STOCK_OPTION       = 'stock'
  CHANGE_OPTION      = 'change'
  HELP_OPTION        = 'help'
  CLEAR_OPTION       = 'clear'
  EXIT_OPTION        = 'exit'

  def run
    clear_screen
    output_interface
    output_cursor

    user_input = ''
    command = ''

    while command != EXIT_OPTION
      user_input = gets.chomp

      args = user_input.split(' ')
      command = args[0]
      # Currently the CLI ignores any options after the first
      option = args[1]

      case command
      when BALANCE_OPTION
        output_balance
      when INSERT_COIN_OPTION
        insert_coin(input: option)
      when STOCK_OPTION
        output_stock
      when CHANGE_OPTION
        output_change
      when HELP_OPTION
        output_options
      when CLEAR_OPTION
        clear_screen
        output_interface
      when EXIT_OPTION
      else
        output_invalid_input
      end

      output_cursor unless command == EXIT_OPTION
    end
  end

  private

  attr_reader :vending_machine

  # Interface output

  def clear_screen
    system 'clear'
  end

  def output_interface
    output_welcome
    puts "\n"
    output_stock
    puts "\n"
    output_change
    puts "\n"
    output_options
  end

  def output_welcome
    puts 'Welcome to Vending Machine'
  end

  def output_cursor
    print '> '
  end

  def output_invalid_input
    output_error(error: 'Invalid Input')
  end

  def output_unimplemented
    output_error(error: 'Unimplemented')
  end

  def output_error(error:)
    puts "ERROR: #{error}"
  end

  # Options output

  def options
    {
      BALANCE_OPTION => 'Output Balance',
      "#{INSERT_COIN_OPTION} <x>" => "Insert Coin (options: #{insert_coin_custom_input_examples})",
      STOCK_OPTION => 'Display current stock',
      CHANGE_OPTION => 'Display current change in machine',
      HELP_OPTION => 'Display these options',
      CLEAR_OPTION => 'Clear history',
      EXIT_OPTION => 'Close CLI'
    }
  end

  def output_options
    puts 'Available Options'
    puts '================='

    options.each do |option, description|
      output_option(option: option, description: description)
    end
  end

  def output_option(option:, description:)
    # Using ljust here to neatly format the options and descriptions
    # +1 to account for the colon on the longest option
    option_string = "#{option}:".ljust(longest_option_length + 1)
    puts "#{option_string} #{description}"
  end

  def longest_option_length
    options.keys.map(&:length).max
  end

  def valid_coin_names
    Coin::VALID_COIN_NAMES
  end

  def insert_coin_custom_input_examples
    valid_coin_names.join(', ')
  end

  # Input Handling

  def output_balance
    puts "Current Balance: #{format_currency(vending_machine.balance)}"
  end

  def output_stock
    products = vending_machine.products

    product_info = products.group_by do |product|
      { name: product.name, price: product.price }
    end.transform_values(&:length)

    puts 'Current Stock'
    puts '============='
    product_info.each do |product_info, quantity|
      name = product_info[:name]
      price = format_currency(product_info[:price])
      puts "#{name} x #{quantity} @ #{price}"
    end
  end

  def output_change
    change = vending_machine.change
    coin_counts = change.group_by(&:name).transform_values(&:count)

    puts 'Current Change'
    puts '=============='
    coin_counts.each do |coin_name, quantity|
      puts "#{coin_name} x #{quantity}"
    end
  end

  def format_currency(value)
    Money.new(value, 'GBP').format
  end

  def insert_coin(input:)
    coin = Coin.from_string(string: input)

    if vending_machine.insert_coin(coin: coin)
      puts 'Coin Inserted'
      output_balance
    else
      output_error(error: "Invalid argument #{input}")
    end
  end
end
