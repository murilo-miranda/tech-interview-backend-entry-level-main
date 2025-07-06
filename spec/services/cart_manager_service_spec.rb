require 'rails_helper'

RSpec.describe CartManagerService, type: :model do
	describe '#call' do
		context 'valid session' do
			let!(:previous_cart) { Cart.create(total_price: 0.0) }
			let(:product) { Product.create(name: "Test Product", price: 10.0) }
			let(:product2) { Product.create(name: "Test Product2", price: 7.0) }
			let!(:cart_item0) { CartItem.create(cart: previous_cart, product: product, quantity: quantity) }
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
				cart = described_class.new(session: session, cart_params: cart_params).call
				expect(cart.id).to eq(previous_cart.id)
			end

			it 'do not create a new cart' do
				expect { 
					described_class.new(session: session, cart_params: cart_params).call
				}.not_to change(Cart, :count)
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
							described_class.new(session: session, cart_params: cart_params).call 
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end

				context 'negative quantity' do
					let(:quantity) { -1 }

					it 'does not register a cart item' do
						expect { 
							described_class.new(session: session, cart_params: cart_params).call 
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end

				context 'quantity not a number' do
					let(:quantity) { "a" }

					it 'does not register a cart item' do
						expect { 
							described_class.new(session: session, cart_params: cart_params).call 
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
							described_class.new(session: session, cart_params: cart_params).call 
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
				expect { described_class.new(session: nil, cart_params: cart_params).call }.to change(Cart, :count).by(1)
				expect { described_class.new(session: nil, cart_params: cart_params).call }.to change(CartItem, :count).by(1)
			end

			it 'return a cart' do
				cart = described_class.new(session: nil, cart_params: cart_params).call
				expect(cart).to be_a(Cart)
			end
		end
	end
end