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

  describe '.request_product' do
    subject { vending_machine.request_product(product_name: product_name) }

    let(:product_name) { 'Pepsi' }

    shared_examples_for 'failed vend' do
      it { should eq VendingResponse.new(error: expected_error) }

      it "should not change the vending machine's change" do
        expect { subject }.not_to change(vending_machine, :change)
      end

      it "should not change the vending machine's stock" do
        expect { subject }.not_to change(vending_machine, :products)
      end

      it "should not change the vending machine's current balance" do
        expect { subject }.not_to change(vending_machine, :balance)
      end
    end

    shared_examples_for 'successful vend' do
      it { should eq VendingResponse.new(vended_product: expected_vended_product, change: expected_change) }

      it "should update the vending machine's change" do
        expect do
          subject
        end.to change {
          vending_machine.change.map(&:value).sort
        }.to(expected_new_change.map(&:value).sort)
      end

      it "should update the vending machine's stock" do
        expect { subject }.to change(vending_machine, :products).to(expected_new_stock)
      end

      it 'empty the current balance' do
        expect { subject }.to change(vending_machine, :balance).to(0)
      end
    end

    context 'for a product not in stock' do
      let(:expected_error) { :out_of_stock }

      include_examples 'failed vend'
    end

    context 'without enough balance' do
      let(:initial_products) { [Product.new(name: product_name, price: 30)] }

      let(:expected_error) { :insufficient_balance }

      before do
        vending_machine.insert_coin(coin: Coin.new(value: 10))
        expect(vending_machine.balance).to eq 10
      end

      include_examples 'failed vend'
    end

    context 'without any balance' do
      let(:initial_products) { [Product.new(name: product_name, price: 30)] }

      let(:expected_error) { :insufficient_balance }

      before do
        expect(vending_machine.balance).to eq 0
      end

      include_examples 'failed vend'
    end

    context 'without enough change in the machine' do
      let(:initial_products) { [Product.new(name: product_name, price: 30)] }

      let(:expected_error) { :insufficient_change }

      before do
        vending_machine.insert_coin(coin: Coin.new(value: 100))
        expect(vending_machine.balance).to eq 100
      end

      include_examples 'failed vend'

      # check that coins in the balance are used for change
      context 'but with enough change in the current balance to vend' do
        before do
          vending_machine.insert_coin(coin: Coin.new(value: 20))
          vending_machine.insert_coin(coin: Coin.new(value: 10))
          expect(vending_machine.balance).to eq 130
        end

        let(:expected_change) { [Coin.new(value: 100)] }
        let(:expected_vended_product) { Product.new(name: product_name, price: 30) }
        let(:expected_new_change) { [Coin.new(value: 20), Coin.new(value: 10)] }
        let(:expected_new_stock) { [] }

        include_examples 'successful vend'
      end
    end

    context 'with exact change' do
      before do
        vending_machine.insert_coin(coin: Coin.new(value: 20))
        vending_machine.insert_coin(coin: Coin.new(value: 10))
        expect(vending_machine.balance).to eq 30
      end

      let(:initial_products) { [Product.new(name: product_name, price: 30)] }

      let(:expected_change) { [] }
      let(:expected_vended_product) { Product.new(name: product_name, price: 30) }
      let(:expected_new_change) { [Coin.new(value: 20), Coin.new(value: 10)] }
      let(:expected_new_stock) { [] }

      include_examples 'successful vend'
    end

    context 'with excess money' do
      before do
        vending_machine.insert_coin(coin: Coin.new(value: 50))
        expect(vending_machine.balance).to eq 50
      end

      let(:initial_products) { [Product.new(name: product_name, price: 30)] }
      let(:initial_change) { [Coin.new(value: 20)] }

      let(:expected_change) { [Coin.new(value: 20)] }
      let(:expected_vended_product) { Product.new(name: product_name, price: 30) }
      let(:expected_new_change) { [Coin.new(value: 50)] }
      let(:expected_new_stock) { [] }

      include_examples 'successful vend'
    end

    context 'when there is a lot in stock' do
      before do
        vending_machine.insert_coin(coin: Coin.new(value: 20))
        vending_machine.insert_coin(coin: Coin.new(value: 10))
        expect(vending_machine.balance).to eq 30
      end

      let(:initial_products) do
        [
          [Product.new(name: product_name, price: 30)] * 20,
          [Product.new(name: 'Foo', price: 30)] * 70,
          [Product.new(name: 'Bar', price: 30)] * 10
        ].flatten
      end

      let(:expected_change) { [] }
      let(:expected_vended_product) { Product.new(name: product_name, price: 30) }
      let(:expected_new_change) { [Coin.new(value: 20), Coin.new(value: 10)] }
      let(:expected_new_stock) do
        [
          [Product.new(name: product_name, price: 30)] * 19,
          [Product.new(name: 'Foo', price: 30)] * 70,
          [Product.new(name: 'Bar', price: 30)] * 10
        ].flatten
      end

      include_examples 'successful vend'
    end

    context 'when there is a lot of change' do
      before do
        vending_machine.insert_coin(coin: Coin.new(value: 50))
        expect(vending_machine.balance).to eq 50
      end

      let(:initial_products) { [Product.new(name: product_name, price: 30)] }
      let(:initial_change) do
        [
          [Coin.new(value: 20)] * 20,
          [Coin.new(value: 5)] * 15,
          [Coin.new(value: 50)] * 5,
          [Coin.new(value: 100)] * 3
        ].flatten
      end

      let(:expected_change) { [Coin.new(value: 20)] }
      let(:expected_vended_product) { Product.new(name: product_name, price: 30) }
      let(:expected_new_change) do
        [
          [Coin.new(value: 5)] * 15,
          [Coin.new(value: 20)] * 19,
          [Coin.new(value: 50)] * 6,
          [Coin.new(value: 100)] * 3
        ].flatten
      end
      let(:expected_new_stock) { [] }

      include_examples 'successful vend'
    end
  end
end
