# frozen_string_literal: true

class Product
  attr_reader :name, :price

  def initialize(name:, price:)
    @name = name
    @price = price
  end

  def ==(other)
    name == other.name &&
      price = other.price
  end
end
