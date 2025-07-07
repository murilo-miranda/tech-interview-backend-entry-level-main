class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def total_price
    cart_items.includes(:product).sum do |cart_item|
      cart_item.product.price * cart_item.quantity
    end
  end

  enum status: { active: 0, abandoned: 1 }

  def mark_as_abandoned
    abandoned! if last_interaction_at < 3.hours.ago
  end
end
