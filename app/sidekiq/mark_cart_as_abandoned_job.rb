class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    active_carts = Cart.where('last_interaction_at < ?', 3.hours.ago)
    active_carts.update_all(status: 'abandoned')
  end
end
