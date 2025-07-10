require 'rails_helper'

RSpec.describe CartItemDeleterService do
  describe '#call' do
    let(:product) { create(:product) }
    let(:cart_params) {
      {
        product_id: product.id,
        quantity: 1
      }
    }

    subject do
      described_class.call(session: session, cart_params: cart_params)
    end

    context 'when session is present' do
      let!(:cart) { create(:shopping_cart) }
  		let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }
			let(:session) { { "cart_id": cart.id } }

			context 'and cart param is valid' do
				it 'removes product from cart and updates cart info' do
					cart = subject

					expect(cart.cart_items.count).to eq(0)
				end

				context 'but product does not exist' do
					let(:cart_params) { {"product_id": 999_999} }

					it 'raises an error' do
						expect {
							subject
						}.to raise_error(ActiveRecord::RecordNotFound)
					end
				end
			end
		end

		context 'when session is not present' do
      let(:session) { { "cart_id": nil } }

			it 'raises an error' do
				expect { 
					described_class.call(session: session, cart_params: cart_params) 
				}.to raise_error(ActiveRecord::RecordNotFound)
			end
		end
  end
end