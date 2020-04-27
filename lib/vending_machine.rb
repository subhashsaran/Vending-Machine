class VendingMachine
  def initialize(products: [], change: [])
    @products = products
    @change = change
  end

  attr_reader :products
end
