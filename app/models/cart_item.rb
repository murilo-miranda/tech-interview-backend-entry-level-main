class CartItem < ApplicationRecord
	belongs_to :cart, touch: :last_interaction_at
	belongs_to :product

	validates :quantity, numericality: { greater_than: 0 }, presence: true
	validates :product_id, uniqueness: { scope: :cart_id, message: "already exists in cart" }
end