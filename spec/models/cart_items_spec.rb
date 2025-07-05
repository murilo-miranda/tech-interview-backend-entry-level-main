require 'rails_helper'

RSpec.describe CartItem, type: :model do
	context 'when validating' do
		it 'validates presence of quantity' do
			cart = Cart.create(total_price: 0.0)
			product = Product.create(name: 'Test Product', price: 10.0)
			cart_item = CartItem.new(cart: cart, product: product)

			expect(cart_item.valid?).to be_falsey
			expect(cart_item.errors[:quantity]).to include("can't be blank")
		end

		context 'numericality of quantity' do
			it 'validates negative quantity' do
				cart = Cart.create(total_price: 0.0)
				product = Product.create(name: 'Test Product', price: 10.0)
				cart_item = CartItem.new(cart: cart, product: product, quantity: -1)
				
				expect(cart_item.valid?).to be_falsey
				expect(cart_item.errors[:quantity]).to include("must be greater than 0")
			end

			it 'validates zero quantity' do
				cart = Cart.create(total_price: 0.0)
				product = Product.create(name: 'Test Product', price: 10.0)
				cart_item = CartItem.new(cart: cart, product: product, quantity: 0)

				expect(cart_item.valid?).to be_falsey
				expect(cart_item.errors[:quantity]).to include("must be greater than 0")
			end
		end
	end

	describe 'associations' do
		it { should belong_to(:cart).class_name('Cart') }			
		it { should belong_to(:product).class_name('Product') }
	end
end