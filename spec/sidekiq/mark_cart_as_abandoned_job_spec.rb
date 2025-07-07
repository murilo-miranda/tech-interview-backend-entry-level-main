require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '.perform' do
    let(:cart) { create(:shopping_cart) }

    it 'marks carts as abandoned' do
      cart.update(last_interaction_at: 3.hours.ago)
      expect { MarkCartAsAbandonedJob.new.perform }.to change { cart.reload.status }.from('active').to('abandoned')
    end
  end
end
