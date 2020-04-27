# frozen_string_literal: true

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
    Money.new(value, 'GBP').format
  end
end
