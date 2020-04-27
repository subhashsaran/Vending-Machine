# frozen_string_literal: true

RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new(products: initial_products, change: initial_change) }

  let(:initial_products) { [] }
  let(:initial_change) { [] }

  describe '.products' do
    subject { vending_machine.products }

    let(:initial_products) do
      [
        Product.new(name: 'Pepsi', price: 65),
        Product.new(name: 'Banana', price: 50)
      ]
    end

    it { should be initial_products }
  end

  describe '.insert_coin' do
    subject { vending_machine.insert_coin(coin: coin) }

    context 'with a valid coin' do
      let(:coin) { Coin.new(value: 20) }

      it 'adds the coin to the users balance' do
        expect { subject }.to change(vending_machine, :balance).from(0).to(coin.value)
      end

      it { should be true }
    end

    context 'with an invalid coin' do
      let(:coin) { Coin.new(value: 21) }

      it 'does not add the coin to the users balance' do
        expect { subject }.not_to change(vending_machine, :balance)
      end

      it { should be false }
    end

    context 'with a non-coin' do
      let(:coin) { 21 }

      it 'does not add the coin to the users balance' do
        expect { subject }.not_to change(vending_machine, :balance)
      end

      it { should be false }
    end
  end
end
