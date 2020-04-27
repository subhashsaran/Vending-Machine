RSpec.describe Product do
  let(:product) { Product.new(name: name, price: price) }

  let(:price) { rand(1..100) }
  let(:name) { ['Pepsi', 'Coke', 'Banana'].sample }

  describe '.price' do
    subject { product.price }

    it 'returns the product price' do
      expect(subject).to eq price
    end
  end

  describe '.name' do
    subject { product.name }

    it 'returns the product name' do
      expect(subject).to eq name
    end
  end
end
