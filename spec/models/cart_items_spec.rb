require 'rails_helper'

RSpec.describe CartItem, type: :model do
	context 'when validating' do
		let(:cart) { Cart.create(total_price: 0.0) }
		let(:product) { Product.create(name: 'Test Product', price: 10.0) }
		
		it 'validates presence of quantity' do
			cart_item = CartItem.new(cart: cart, product: product)

			expect(cart_item.valid?).to be_falsey
			expect(cart_item.errors[:quantity]).to include("can't be blank")
		end

		context 'numericality of quantity' do
			it 'validates negative quantity' do
				cart_item = CartItem.new(cart: cart, product: product, quantity: -1)
				
				expect(cart_item.valid?).to be_falsey
				expect(cart_item.errors[:quantity]).to include("must be greater than 0")
			end

			it 'validates zero quantity' do
				cart_item = CartItem.new(cart: cart, product: product, quantity: 0)

				expect(cart_item.valid?).to be_falsey
				expect(cart_item.errors[:quantity]).to include("must be greater than 0")
			end
		end

		it 'validates product id uniqueness' do
			cart_item = CartItem.new(cart: cart, product: product, quantity: 1)
			cart_item.save

			cart_item2 = CartItem.new(cart: cart, product: product, quantity: 1)

			expect(cart_item2.valid?).to be_falsey
			expect(cart_item2.errors[:product_id]).to include("already exists in cart")
		end
	end

	describe 'associations' do
		it { should belong_to(:cart).class_name('Cart') }			
		it { should belong_to(:product).class_name('Product') }
	end
end