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
		cart = Cart.find(@session[:cart_id])
		product = Product.find(@cart_params[:product_id])
		cart_item = CartItem.find_by!(cart: cart, product_id: product)

		ensure_valid_quantity!(cart_item)

		new_quantity = @cart_params[:quantity].to_i + cart_item.quantity

		cart_item.update!(quantity: new_quantity)

		cart
	end

	private

	def load_or_create_cart
		@session[:cart_id] ||= Cart.create!(total_price: 0.0).id
		Cart.find(@session[:cart_id])
	end

	def ensure_valid_quantity!(cart_item)
		if @cart_params[:quantity].to_i <= 0
			cart_item.errors.add(:quantity, "must be greater than 0")
			raise ActiveRecord::RecordInvalid, cart_item
		end
	end
end