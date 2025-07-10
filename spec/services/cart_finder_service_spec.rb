require 'rails_helper'

RSpec.describe CartFinderService do
  describe '#call' do
    let(:session) { { "cart_id": cart_id } }

    context 'when session is present' do
      let!(:cart) { create(:shopping_cart) }
      let(:cart_id) { cart.id }

      it 'returns a cart' do
        expect(described_class.call(session: session)).to eq(cart)
      end
    end

    context 'when session is not present' do
      let(:cart_id) { nil }
      
			it 'raises an error' do
				expect { described_class.call(session: session) }.to raise_error(ActiveRecord::RecordNotFound)
			end
		end
  end
end