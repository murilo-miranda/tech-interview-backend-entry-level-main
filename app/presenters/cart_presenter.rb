class CartPresenter
	def initialize(cart)
		@cart = cart
	end

	def as_json
		{
			id: @cart.id,
			products: @cart.cart_items.includes(:product).map do |cart_item|
				{
					id: cart_item.product.id,
					name: cart_item.product.name,
					quantity: cart_item.quantity,
					unit_price: cart_item.product.price.to_f,
					total_price: (cart_item.product.price * cart_item.quantity).to_f
				}
			end,
			total_price: @cart.total_price.to_f
		}
	end
end