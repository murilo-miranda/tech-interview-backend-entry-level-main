require 'rails_helper'

RSpec.describe CartManagerService, type: :model do
	describe '#call' do
		let(:session) { { "cart_id": 1 } }
		let(:cart_params) {
			{
				product_id: 1,
				quantity: 1
			}
		}

		subject do
			described_class.call(session: session, cart_params: cart_params, action: action)
		end

		context 'when show action' do
			let(:action) { "show" }
			
			it 'delegates to CartFinderService' do
				expect(CartFinderService).to receive(:call).with(session: session, cart_params: cart_params)
				subject
			end
		end

		context 'when create action' do
			let(:action) { "create" }
			
			it 'delegates to CartItemRegisterService' do
				expect(CartItemRegisterService).to receive(:call).with(session: session, cart_params: cart_params)
				subject
			end
		end

		context 'when add_item action' do
			let(:action) { "add_item" }
			
			it 'delegates to CartItemUpdaterService' do
				expect(CartItemUpdaterService).to receive(:call).with(session: session, cart_params: cart_params)
				subject
			end
		end

		context 'when remove_item action' do
			let(:action) { "remove_item" }
			
			it 'delegates to CartItemDeleterService' do
				expect(CartItemDeleterService).to receive(:call).with(session: session, cart_params: cart_params)
				subject
			end
		end
	end
end