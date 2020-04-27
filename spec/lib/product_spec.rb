RSpec.describe Product do
  let(:product) { Product.new(name: name, price: price) }

  let(:price) { rand(1..100) }
  let(:name) { ['Pepsi', 'Coke', 'Banana'].sample }

  describe '.price' do
    subject { product.price }

    it { should be price }
  end

  describe '.name' do
    subject { product.name }

    it { should be name }
  end
end
