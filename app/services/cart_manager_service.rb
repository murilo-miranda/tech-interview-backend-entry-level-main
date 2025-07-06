class CartManagerService
	def initialize(session:, cart_params:)
		@session = session || {}
		@cart_params = cart_params
	end
	
	def call()
		create_item
	end

	private

	def create_item
		ActiveRecord::Base.transaction do
			cart = load_or_create_cart
			CartItem.create!(@cart_params.merge(cart: cart))
			cart
		end
	end

	def load_or_create_cart
		@session[:cart_id] ||= Cart.create!(total_price: 0.0).id
		Cart.find(@session[:cart_id])
	end
end