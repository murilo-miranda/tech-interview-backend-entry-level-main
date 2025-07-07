require 'rails_helper'
RSpec.describe RemoveAbandonedCartJob, type: :job do
  describe '.perform' do
    let!(:cart) { create(:shopping_cart, :abandoned) }

    it 'deletes abandoned carts' do
      cart.update(last_interaction_at: 7.days.ago)
      expect { RemoveAbandonedCartJob.new.perform }.to change { Cart.count }.by(-1)
    end
  end
end
