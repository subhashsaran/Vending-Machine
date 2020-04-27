Dir[File.join(__dir__, '**', '*.rb')].sort.each { |file| require file }
require 'money'
I18n.enforce_available_locales = false
Money.locale_backend = nil
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

class CLI
  def initialize
    @vending_machine = VendingMachine.new(
      products: initial_products,
      change: initial_change
    )
  end

  BALANCE_OPTION     = 'balance'
  INSERT_COIN_OPTION = 'insert'
  HELP_OPTION        = 'help'
  CLEAR_OPTION       = 'clear'
  EXIT_OPTION        = 'exit'

  def run
    clear_screen
    output_interface
    output_cursor

    user_input = ''

    while user_input != EXIT_OPTION
      user_input = gets.chomp

      case user_input
      when BALANCE_OPTION
        output_balance
      when INSERT_COIN_OPTION
        output_unimplemented
      when HELP_OPTION
        output_options
      when CLEAR_OPTION
        clear_screen
        output_interface
      when EXIT_OPTION
      else
        output_invalid_input
      end

      output_cursor unless user_input == EXIT_OPTION
    end
  end

  private

  attr_reader :vending_machine

  def initial_products
    []
  end

  def initial_change
    []
  end

  def clear_screen
    system 'clear'
  end

  def output_interface
    output_welcome
    puts "\n"
    output_options
  end

  def output_welcome
    puts 'Welcome to Vending Machine'
  end

  def output_options
    options = {
      BALANCE_OPTION     => 'Output Balance',
      INSERT_COIN_OPTION => 'Insert Coin',
      HELP_OPTION        => 'Display these options',
      CLEAR_OPTION       => 'Clear history',
      EXIT_OPTION        => 'Close CLI'
    }
    longest_option_length = options.keys.map(&:length).max

    puts 'Available Options'
    puts '================='

    options.each do |option, description|
      # Using ljust here to neatly format the options and descriptions
      # +1 to account for the colon
      option_string = "#{option}:".ljust(longest_option_length + 1)
      puts "#{option_string} #{description}"
    end
  end

  def output_cursor
    print '> '
  end

  def output_invalid_input
    puts 'Invalid Input'
  end

  def output_unimplemented
    puts 'Unimplemented'
  end

  def output_balance
    puts "Current Balance: #{format_currency(vending_machine.balance)}"
  end

  def format_currency(value)
    Money.new(value, 'GBP').format
  end
end
