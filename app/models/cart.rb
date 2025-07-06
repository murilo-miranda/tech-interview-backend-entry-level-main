class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def total_price
    cart_items.includes(:product).sum do |cart_item|
      cart_item.product.price * cart_item.quantity
    end
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

end
