require 'rails_helper'

RSpec.describe CartItemUpdaterService do
  describe "#call" do
    let!(:previous_cart) { create(:shopping_cart) }
    let(:previous_cart_id) { previous_cart.id }
		let(:product) { create(:product) }
    let(:product_id) { product.id }
		let!(:cart_item) { CartItem.create(cart: previous_cart, product: product, quantity: quantity) }
		let(:quantity) { 3 }
    let(:params_quantity) { quantity }
		let(:cart_params) {
			{
				"product_id": product_id,
				"quantity": params_quantity
			}
		}

    subject do
      described_class.call(session: session, cart_params: cart_params)
    end
    
    context 'when session is present' do
      let(:session) { { "cart_id": previous_cart_id } }

			context 'and cart param is valid' do
        let(:additional_quantity) { 2 }
				let(:cart_params) {
					{
						"product_id": product_id,
						"quantity": additional_quantity
					}
				}
        let(:expected_total_price) { product.price * 5 }
        let(:expect_new_quantity) { quantity + additional_quantity }

				it 'updates cart info' do
					cart = subject
					expect(cart_item.reload.quantity).to eq(5)
					expect(cart.total_price.to_f).to eq(expected_total_price)
				end

				context 'but product does not exist' do
          let(:product_id) { 999_999 }

					it 'raises an error' do
						expect {
							subject
						}.to raise_error(ActiveRecord::RecordNotFound)
					end
				end
			end

			context 'and cart param is not valid' do
				context 'due to negative quantity' do
          let(:params_quantity) { -1 }

					it 'raises an error' do
						expect { 
							subject
						}.to raise_error(ActiveRecord::RecordInvalid)
					end
				end

				context 'due to zero quantity' do
          let(:params_quantity) { 0 }

					it 'raises an error' do
						expect { 
              subject
						}.to raise_error(ActiveRecord::RecordInvalid)
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