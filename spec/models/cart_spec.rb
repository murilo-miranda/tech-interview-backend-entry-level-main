require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'mark_as_abandoned' do
    let!(:shopping_cart) { create(:shopping_cart, :inactivity_of_3_hours) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let!(:shopping_cart) { create(:shopping_cart, :abandoned, :inactivity_of_7_days) }

    it 'removes the shopping cart if abandoned for a certain time' do
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end

  describe 'associations' do
    it { should have_many(:products).through(:cart_items) }
    it { should have_many(:cart_items).class_name('CartItem') }
  end
end
