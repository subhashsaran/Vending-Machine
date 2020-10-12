# frozen_string_literal: true

# This is one of the two core building blocks of the system, Products represent an object that can be loaded into
# and purchased from the VendingMachine.
#
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

  def matches_name?(name)
    self.name.casecmp?(name)
  end
end
