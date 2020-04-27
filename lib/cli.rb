# frozen_string_literal: true

Dir[File.join(__dir__, '**', '*.rb')].sort.each { |file| require file }

# This runs the interface for interacting with the VendingMachine system.
# It builds a VendingMachine using the config in `config/initial.json` and then provides
# a set of commands for interacting with it.
# The main loop is located in `run` where the initial interface is displayed and then user input
# is captured and distributed to the various actions within the CLI.
#
class CLI
  def initialize
    @vending_machine = VendingMachine.new(
      products: initial_products,
      change: initial_change
    )
  end

  BALANCE_OPTION     = 'balance'
  INSERT_COIN_OPTION = 'insert'
  PURCHASE_OPTION    = 'purchase'
  STOCK_OPTION       = 'stock'
  CHANGE_OPTION      = 'change'
  RELOAD_OPTION      = 'reload'
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
      when PURCHASE_OPTION
        purchase_product(input: option)
      when RELOAD_OPTION
        reload_vending_machine(input: option)
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
  rescue Interrupt
    puts "\nExiting"
  end

  private

  attr_reader :vending_machine

  def config_loader
    @config_loader ||= ConfigLoader.new
  end

  def initial_products
    config_loader.initial_products
  end

  def initial_change
    config_loader.initial_change
  end

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
      "#{PURCHASE_OPTION} <x>" => 'Attempt to purchase a product (case sensitive)',
      "#{RELOAD_OPTION} <x>" => 'Reload vending machine back to initial values (options: products, change)',
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
    puts 'Current Stock'
    puts '============='

    products = vending_machine.products

    if products.any?
      product_info = products.group_by do |product|
        { name: product.name, price: product.price }
      end.transform_values(&:length)

      product_info.each do |product_info, quantity|
        name = product_info[:name]
        price = format_currency(product_info[:price])
        puts "#{name} x #{quantity} @ #{price}"
      end
    else
      puts 'No products in stock'
    end
  end

  def output_change
    puts 'Current Change'
    puts '=============='

    change = vending_machine.change

    if change.any?
      coin_counts = change.group_by(&:name).transform_values(&:count)

      coin_counts.each do |coin_name, quantity|
        puts "#{coin_name} x #{quantity}"
      end
    else
      puts 'No change available'
    end
  end

  def format_currency(value)
    CurrencyRenderer.render_currency(value: value)
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

  def purchase_product(input:)
    response = vending_machine.request_product(product_name: input)

    return output_error(error: response.error) if response.error?

    puts "#{response.vended_product_name} vended"

    if response.change?
      puts "#{response.total_change} is dispensed"
      puts "It consists of: #{response.change_coin_names.join(', ')}"
    else
      puts 'No change is dispensed'
    end
  end

  def reload_vending_machine(input:)
    return reload_products if input == 'products'
    return reload_change if input == 'change'

    output_invalid_input
  end

  def reload_products
    vending_machine.reset_products(new_products: initial_products)
    puts 'Products reloaded back to initial contents'
  end

  def reload_change
    vending_machine.reset_change(new_change: initial_change)
    puts 'Change reloaded back to initial contents'
  end
end
