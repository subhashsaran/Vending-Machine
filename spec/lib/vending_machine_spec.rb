RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new(products: products, change: change) }

  let(:products) { [] }
  let(:change) { [] }

  describe '.products' do
    subject { vending_machine.products }

    let(:products) {
      [
        Product.new(name: 'Pepsi', price: 65),
        Product.new(name: 'Banana', price: 50)
      ]
    }

    it { should be products }
  end
end
