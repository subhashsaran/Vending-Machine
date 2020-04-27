# frozen_string_literal: true

RSpec.describe VendingResponse do
  let(:vending_response) { VendingResponse.new(vended_product: product, change: change, error: error) }

  let(:product) { Product.new(name: 'Foo', price: 20) }
  let(:change) { [] }
  let(:error) { nil }

  describe '.vended_product_name' do
    subject { vending_response.vended_product_name }

    context 'with a vended product' do
      it { should eq product.name }
    end

    context 'without a vended product' do
      let(:product) { nil }

      it { should eq nil }
    end
  end

  describe '.error?' do
    subject { vending_response.error? }

    context 'with an error' do
      let(:error) { :foo_error }

      it { should eq true }
    end

    context 'without an error' do
      it { should eq false }
    end
  end

  describe '.change?' do
    subject { vending_response.change? }

    context 'with coins in the change array' do
      let(:change) { [Coin.new(value: 100)] }

      it { should eq true }
    end

    context 'without an error' do
      it { should eq false }
    end
  end

  describe '.total_change' do
    subject { vending_response.total_change }

    context 'with change' do
      let(:change) do
        [
          Coin.new(value: 100),
          Coin.new(value: 20),
          Coin.new(value: 10),
          Coin.new(value: 2),
          Coin.new(value: 2)
        ]
      end

      it { should eq '£1.34' }
    end

    context 'with no change' do
      it { should eq '£0.00' }
    end
  end

  describe '.change_coin_names' do
    subject { vending_response.change_coin_names }

    context 'with change' do
      let(:change) do
        [
          Coin.new(value: 100),
          Coin.new(value: 20),
          Coin.new(value: 10),
          Coin.new(value: 2),
          Coin.new(value: 2)
        ]
      end

      it { should eq ['£1', '20p', '10p', '2p', '2p'] }
    end

    context 'with no change' do
      it { should eq [] }
    end
  end

  describe '.vended_product' do
    subject { vending_response.vended_product }

    context 'with a product' do
      it { should eq product }
    end

    context 'with no product' do
      let(:product) { nil }

      it { should eq nil }
    end
  end

  describe '.change' do
    subject { vending_response.change }

    context 'with change' do
      let(:change) do
        [
          Coin.new(value: 100),
          Coin.new(value: 20),
          Coin.new(value: 10),
          Coin.new(value: 2),
          Coin.new(value: 2)
        ]
      end

      it { should eq change }
    end

    context 'with no change' do
      it { should eq [] }
    end
  end

  describe '.error' do
    subject { vending_response.error }

    context 'with an error' do
      let(:error) { :foo_error }

      it { should eq :foo_error }
    end

    context 'without an error' do
      it { should eq nil }
    end
  end
end
