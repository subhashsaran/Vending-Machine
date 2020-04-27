# frozen_string_literal: true

RSpec.describe Coin do
  let(:valid_coins) { [1, 2, 5, 10, 20, 50, 100, 200] }

  describe '#valid_coins' do
    it 'returns valid coins' do
      expect(Coin.valid_coins.sort).to eq valid_coins.sort
    end
  end

  describe '.value' do
    subject { coin.value }

    let(:coin) { Coin.new(value: coin_value) }
    let(:coin_value) { valid_coins.sample }

    it { should be coin_value }
  end

  describe '.valid?' do
    subject { coin.valid? }

    let(:coin) { Coin.new(value: coin_value) }

    context 'when the coin is a valid coin' do
      let(:coin_value) { valid_coins.sample }

      it { should be true }
    end

    context 'when the coin is an invalid coin' do
      let(:coin_value) { valid_coins.sample + 2 }

      it { should be false }
    end
  end
end
