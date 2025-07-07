class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    active_carts = Cart.where("last_interaction_at < ? AND status = ?", 3.hours.ago, 0)
    active_carts.each(&:mark_as_abandoned)
  end
end
