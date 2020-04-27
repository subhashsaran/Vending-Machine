# frozen_string_literal: true

class ConfigLoader
  CONFIG_PATH = File.join(__dir__, '..', 'config', 'initial.json')

  def initial_products
    stock_data.map do |product_name, product_details|
      price = parse_price_from_config(name: product_name, raw_price: product_details['price'])
      quantity = parse_quantity_from_config(name: product_name, raw_quantity: product_details['quantity'])

      quantity.times.map do
        Product.new(name: product_name, price: price)
      end
    end.flatten.compact
  end

  def initial_change
    change_data.map do |coin, quantity|
      quantity = parse_quantity_from_config(name: coin, raw_quantity: quantity)

      quantity.to_i.times.map do
        Coin.from_string(string: coin)
      end
    end.flatten.compact
  end

  private

  def initial_config
    JSON.parse(File.open(CONFIG_PATH).read)
  end

  def stock_data
    initial_config['stock'] || {}
  end

  def change_data
    initial_config['change'] || {}
  end

  def parse_price_from_config(name:, raw_price:)
    parse_integer_value_from_config(name: name, raw_value: raw_price, type: :price)
  end

  def parse_quantity_from_config(name:, raw_quantity:)
    parse_integer_value_from_config(name: name, raw_value: raw_quantity, type: :quantity)
  end

  def parse_integer_value_from_config(name:, raw_value:, type:)
    parsed_value = begin
      raw_value.to_i
    rescue
      0
    end

    return parsed_value if parsed_value.positive?

    raise "Invalid #{type} for #{name} in config file: #{raw_value}. Must be positive integer."
  end
end
