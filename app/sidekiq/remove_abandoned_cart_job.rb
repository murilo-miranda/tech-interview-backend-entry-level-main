class RemoveAbandonedCartJob
  include Sidekiq::Job

  def perform(*arg)
    abandoned_carts = Cart.where("last_interaction_at < ? AND status = ?", 7.days.ago, 1)
    abandoned_carts.each(&:remove_if_abandoned)
  end
end