class VendingMachine
  def initialize(products: [], change: [])
    @products = products
    @change = change

    @inserted_coins = []
  end

  attr_reader :products

  def balance
    inserted_coins.map(&:value).sum
  end

  def insert_coin(coin:)
    return false unless coin.is_a?(Coin)
    return false unless coin.valid?

    inserted_coins << coin
    true
  end

  private

  attr_reader :inserted_coins
end
