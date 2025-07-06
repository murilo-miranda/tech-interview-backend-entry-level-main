require 'rails_helper'

RSpec.describe CartPresenter do
	describe 'as_json' do
		let!(:cart) { Cart.create(total_price: 0.0) }
		let!(:product) { Product.create(name: "Test Product", price: 10.0) }
		let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: quantity) }
		let(:quantity) { 1 }
		let(:expected_response) {
			{
				"id": cart.id,
				"products": [{
					"id": product.id,
					"name": product.name,
					"quantity": quantity,
					"unit_price": product.price.to_f,
					"total_price": (product.price * 1).to_f
				}],
				"total_price": (product.price * 1).to_f
			}
		}
		
		it 'returns cart info in json format' do
			presenter = CartPresenter.new(cart)

			expect(presenter.as_json).to eq(expected_response)
		end
	end
end