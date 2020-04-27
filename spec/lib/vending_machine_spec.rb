# frozen_string_literal: true

RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new(products: initial_products, change: initial_change) }

  let(:initial_products) { [] }
  let(:initial_change) { [] }

  context 'with an invalid coin in the initial load' do
    let(:initial_change) do
      [
        Coin.new(value: -1),
        Coin.new(value: 200)
      ]
    end

    it 'filters out the coin' do
      expect(vending_machine.change).to eq([Coin.new(value: 200)])
    end
  end

  describe '.products' do
    subject { vending_machine.products }

    let(:initial_products) do
      [
        Product.new(name: 'Pepsi', price: 65),
        Product.new(name: 'Banana', price: 50)
      ]
    end

    it { should eq initial_products }
  end

  describe '.change' do
    subject { vending_machine.change }

    let(:initial_change) do
      [
        Coin.new(value: 20),
        Coin.new(value: 200)
      ]
    end

    it { should eq initial_change }
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
