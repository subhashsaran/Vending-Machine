class Coin
  VALID_COINS = [1, 2, 5, 10, 20, 50, 100, 200]

  class << self
    def valid_coins
      Coin::VALID_COINS
    end
  end

  attr_reader :value

  def initialize(value:)
    @value = value
  end

  def valid?
    Coin.valid_coins.include?(value)
  end
end
