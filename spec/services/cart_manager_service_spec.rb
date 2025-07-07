require 'rails_helper'

RSpec.describe CartManagerService, type: :model do
	describe '#call' do
		context 'valid session' do
			let!(:previous_cart) { Cart.create(total_price: 0.0) }
			let(:product) { Product.create(name: "Test Product", price: 10.0) }
			let(:product2) { Product.create(name: "Test Product2", price: 7.0) }
			let!(:cart_item) { CartItem.create(cart: previous_cart, product: product, quantity: quantity) }
			let(:quantity) { 1 }
			let(:cart_params) {
				{
					"product_id": product2.id,
					"quantity": quantity
				}
			}
			let(:session) {
				{
					"cart_id": previous_cart.id
				}
			}

			it 'registers a cart item for cart from previous session' do
				cart = described_class.call(session: session, cart_params: cart_params)
				expect(cart.id).to eq(previous_cart.id)
			end

			it 'do not create a new cart' do
				expect { 
					described_class.call(session: session, cart_params: cart_params)
				}.not_to change(Cart, :count)
			end

			context 'product already in cart' do
				let(:cart_params) {
					{
						"product_id": product.id,
						"quantity": quantity
					}
				}
				
				it 'raise an error' do
					expect { 
						described_class.call(session: session, cart_params: cart_params) 
					}.to raise_error(ActiveRecord::RecordInvalid)
				end
			end

			context 'invalid cart params' do
				let(:cart_params) {
					{
						"product_id": product.id,
						"quantity": quantity
					}
				}

				context 'quantity zero' do
					let(:quantity) { 0 }

					it 'does not register a cart item' do
						expect { 
							described_class.call(session: session, cart_params: cart_params) 
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end

				context 'negative quantity' do
					let(:quantity) { -1 }

					it 'does not register a cart item' do
						expect { 
							described_class.call(session: session, cart_params: cart_params) 
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end

				context 'quantity not a number' do
					let(:quantity) { "a" }

					it 'does not register a cart item' do
						expect { 
							described_class.call(session: session, cart_params: cart_params) 
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end

				context 'product does not exist' do
					let(:quantity) { 1}
					let(:cart_params) {
						{
							"product_id": 999_999,
							"quantity": quantity
						}
					}

					it 'does not register a cart item' do
						expect { 
							described_class.call(session: session, cart_params: cart_params) 
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end
			end
		end

		context 'invalid session' do
			let(:product) { Product.create(name: "Test Product", price: 10.0) }
			let(:quantity) { 1 }
			let(:cart_params) {
				{
					"product_id": product.id,
					"quantity": quantity
				}
			}

			it 'creates a new cart and registers a cart item' do
				expect { described_class.call(session: nil, cart_params: cart_params) }.to change(Cart, :count).by(1)
				expect { described_class.call(session: nil, cart_params: cart_params) }.to change(CartItem, :count).by(1)
			end

			it 'return a cart' do
				cart = described_class.call(session: nil, cart_params: cart_params)
				expect(cart).to be_a(Cart)
			end
		end
	end

	describe '#find_cart' do
		let(:cart) { Cart.create }
		let(:session) { { "cart_id": cart.id } }

		context 'when session is present' do
			it 'returns a cart' do
				expect(described_class.find_cart(session: session)).to eq(cart)
			end
		end

		context 'when session is not present' do
			it 'raises an error' do
				expect { described_class.find_cart(session: nil) }.to raise_error(ActiveRecord::RecordNotFound)
			end
		end
	end

	describe '#update' do
		let!(:previous_cart) { Cart.create(total_price: 0.0) }
		let(:product) { Product.create(name: "Test Product", price: 10.0) }
		let!(:cart_item) { CartItem.create(cart: previous_cart, product: product, quantity: quantity) }
		let(:quantity) { 3 }
		let(:cart_params) {
			{
				"product_id": product.id,
				"quantity": quantity
			}
		}

		context 'when session is present' do
			let(:session) { { "cart_id": previous_cart.id } }

			context 'and cart param is valid' do
				let(:updating_cart_params) {
					{
						"product_id": product.id,
						"quantity": 2
					}
				}

				it 'updates cart info' do
					cart = described_class.update(session: session, cart_params: updating_cart_params)
					expect(cart_item.reload.quantity).to eq(5)
					expect(cart.total_price).to eq(50.0)
				end

				context 'but product does not exist' do
					let(:updating_cart_params) {
						{
							"product_id": 999_999,
							"quantity": 2
						}
					}

					it 'raises an error' do
						expect {
							described_class.update(session: session, cart_params: updating_cart_params)
						}.to raise_error(ActiveRecord::RecordNotFound)
					end
				end
			end

			context 'and cart param is not valid' do
				context 'due to negative quantity' do
					let(:invalid_params) {
						{
							"product_id": product.id,
							"quantity": -1
						}
					}

					it 'raises an error' do
						expect { 
							described_class.update(session: session, cart_params: invalid_params)
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end

				context 'due to zero quantity' do
					let(:invalid_params) {
						{
							"product_id": product.id,
							"quantity": 0
						}
					}

					it 'raises an error' do
						expect { 
							described_class.update(session: session, cart_params: invalid_params)
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end
			end
		end

		context 'when session is not present' do
			it 'raises an error' do
				expect { 
					described_class.update(session: nil, cart_params: cart_params) 
				}.to raise_error(ActiveRecord::RecordNotFound)
			end
		end
	end
end