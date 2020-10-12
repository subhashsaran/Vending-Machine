# frozen_string_literal: true

# The VendingMachine represents the concept around which the system is built.
# It contains a store of Products and two stores of Coins.
#
# The Product store represents the objects it can vend to the user.
# The first Coin store, the change, is a collection of coins that can be returned to the user
# when they insert too much money for the object they have purchased.
# The second Coin store, the inserted_coins attribute, is the collection of coins the user has
# inserted but have not yet been used to purchase something. This represents the user's current
# balance. Once a purchase has been made this will be added to the change pile.
#
# The public interface for VendingMachine provides ways to interact with these three stores primarily
# by adding to the current balance or purchasing an item.
#
class VendingMachine
  def initialize(products: [], change: [])
    reset_products(new_products: products)
    reset_change(new_change: change)

    @inserted_coins = []
  end

  attr_reader :products, :change

  def reset_products(new_products:)
    @products = new_products.compact
  end

  def reset_change(new_change:)
    @change = new_change.compact.select(&:valid?)
  end

  def balance
    inserted_coins.map(&:value).sum
  end

  def insert_coin(coin:)
    return false unless coin.is_a?(Coin)
    return false unless coin.valid?

    inserted_coins << coin
    true
  end

  def request_product(product_name:)
    return VendingResponse.new(error: :out_of_stock) unless product_in_stock?(name: product_name)
    return VendingResponse.new(error: :insufficient_balance) unless can_afford_product?(name: product_name)
    return VendingResponse.new(error: :insufficient_change) unless can_give_change_for?(name: product_name)

    product = find_cheapest_product(name: product_name)
    change_for_purchase = change_for(name: product_name)

    remove_product_from_stock(product: product)
    deposit_current_balance_in_change
    remove_change(removed_change: change_for_purchase)

    VendingResponse.new(
      vended_product: product,
      change: change_for_purchase
    )
  end

  private

  attr_reader :inserted_coins

  def find_cheapest_product(name:)
    products.select { |product| product.matches_name?(name) }.min_by(&:price)
  end

  def product_in_stock?(name:)
    products.find { |product| product.matches_name?(name) }
  end

  def product_price(name:)
    find_cheapest_product(name: name).price
  end

  def can_afford_product?(name:)
    product_price(name: name) <= balance
  end

  def can_give_change_for?(name:)
    !!change_for(name: name)
  end

  # This generates change by gathering all coins available to the machine and sorting them from large to small.
  # Then it iterates over each of those coins and adds them to the pile of change to be returned if they are
  # smaller than the amount of change we have yet to gather together.
  # If after iterating over all the coins we still have remaining value then the machine doesn't have the coins
  # required to provide change to the user
  def change_for(name:)
    price = product_price(name: name)

    remaining_value = balance - price
    selected_change = []

    coins_available_for_change = (inserted_coins + change).sort.reverse

    coins_available_for_change.each do |coin|
      next if coin.value > remaining_value

      selected_change << coin
      remaining_value -= coin.value
    end

    return false unless remaining_value == 0

    selected_change
  end

  def remove_product_from_stock(product:)
    products.delete_at(products.index(product))
  end

  def deposit_current_balance_in_change
    change << inserted_coins
    change.flatten!

    inserted_coins.clear
  end

  def remove_change(removed_change:)
    removed_change.each do |coin|
      change.delete_at(change.index(coin))
    end
  end
end
