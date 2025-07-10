require 'rails_helper'

RSpec.describe CartItemRegisterService do
  describe '#call' do
    let!(:previous_cart) { create(:shopping_cart) }
    let(:previous_cart_id) { previous_cart.id }
    let(:product) { create(:product) }
    let(:product_id) { product.id }
    let(:product2) { create(:product) }
    let(:product2_id) { product2.id }
    let!(:cart_item) { CartItem.create(cart: previous_cart, product: product, quantity: quantity) }
    let(:quantity) { 1 }
    let(:cart_params) {
      {
        "product_id": product2_id,
        "quantity": quantity
      }
    }
    let(:session) { { "cart_id": previous_cart_id } }

    context 'when session is present' do
      let!(:cart) { create(:shopping_cart) }
      let(:cart_id) { cart.id }

      it 'registers a cart item for cart from previous session' do
        cart = described_class.call(session: session, cart_params: cart_params)
				expect(cart.id).to eq(previous_cart_id)
      end

      it 'do not create a new cart' do
				expect { 
					described_class.call(session: session, cart_params: cart_params)
				}.not_to change(Cart, :count)
			end

      context 'product already in cart' do
        let(:cart_params) {
          {
            "product_id": product_id,
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

    context 'when session is not present' do
      let(:session) { {cart_id: nil} }
      
			it 'creates a new cart and registers a cart item' do
				expect { 
          described_class.call(session: session, cart_params: cart_params) 
        }.to change(Cart, :count).by(1)
         .and change(CartItem, :count).by(1)
			end

			it 'return a cart' do
				cart = described_class.call(session: session, cart_params: cart_params)
				expect(cart).to be_a(Cart)
			end
		end
  end
end