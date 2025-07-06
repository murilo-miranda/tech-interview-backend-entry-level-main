class CartManagerService
	def initialize(session:, cart_params:)
		@session = session || {}
		@cart_params = cart_params
	end
	
	def self.call(session:, cart_params:)
		new(session: session, cart_params: cart_params).create_item
	end

	def create_item
		ActiveRecord::Base.transaction do
			cart = load_or_create_cart
			CartItem.create!(@cart_params.merge(cart: cart))
			cart
		end
	end

	def self.find_cart(session:)
		new(session: session, cart_params: nil).find_cart
	end

	def find_cart()
		Cart.find(@session[:cart_id])
	end

	def self.update(session:, cart_params:)
		new(session: session, cart_params: cart_params).update
	end

	def update
		ActiveRecord::Base.transaction do
			cart = Cart.find(@session[:cart_id])
			cart_item = CartItem.find_by!(cart: cart, product_id: @cart_params[:product_id])
			cart_item.update!(quantity: @cart_params[:quantity])
			cart
		end
	end

	private

	def load_or_create_cart
		@session[:cart_id] ||= Cart.create!(total_price: 0.0).id
		Cart.find(@session[:cart_id])
	end
end