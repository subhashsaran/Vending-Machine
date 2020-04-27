# frozen_string_literal: true

# This represents the response given by the VendingMachine when a purchase attempt is made.
# It can either be successful, containing a product and a collection of coins, or negative, where it
# will contain neither change or a vended product and will come with an error message.
#
# This class was created to provide a neater way of returning data back from request_product than just
# returning a hash with the three pieces of information.
class VendingResponse
  attr_reader :vended_product, :change, :error

  def initialize(vended_product: nil, change: [], error: nil)
    @vended_product = vended_product
    @change = change
    @error = error
  end

  def vended_product_name
    vended_product&.name
  end

  def error?
    !!error
  end

  def change?
    change.any?
  end

  def total_change
    format_currency(change.map(&:value).sum)
  end

  def change_coin_names
    change.map(&:name)
  end

  def ==(other)
    error == other.error &&
      vended_product == other.vended_product &&
      change == other.change
  end

  private

  def format_currency(value)
    CurrencyRenderer.render_currency(value: value)
  end
end
