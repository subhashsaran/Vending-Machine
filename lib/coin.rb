# frozen_string_literal: true

class Coin
  COINS = {
    '£2' => 200,
    '£1' => 100,
    '50p' => 50,
    '20p' => 20,
    '10p' => 10,
    '5p' => 5,
    '2p' => 2,
    '1p' => 1
  }.freeze
  VALID_COIN_NAMES = COINS.keys.freeze
  VALID_COIN_VALUES = COINS.values.freeze

  class << self
    def valid_coins
      Coin::VALID_COIN_VALUES
    end

    def from_string(string:)
      value = Coin::COINS[string]
      return Coin.new(value: value) unless value.nil?

      nil
    end
  end

  attr_reader :value

  def initialize(value:)
    @value = value
  end

  def valid?
    Coin.valid_coins.include?(value)
  end

  def name
    COINS.invert[value]
  end

  def ==(other)
    value == other.value
  end

  def <=>(other)
    value <=> other.value
  end
end
