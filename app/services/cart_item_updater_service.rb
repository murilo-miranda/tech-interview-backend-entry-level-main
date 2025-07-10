class CartItemUpdaterService
  def initialize(**args)
    @session = args[:session]
    @cart_params = args[:cart_params]
  end

  def self.call(**args)
    new(**args).call
  end

  def call
    cart = Cart.find(@session[:cart_id])
		product = Product.find(@cart_params[:product_id])
		cart_item = CartItem.find_by!(cart: cart, product_id: product)

		ensure_valid_quantity!(cart_item)

		new_quantity = @cart_params[:quantity].to_i + cart_item.quantity

		cart_item.update!(quantity: new_quantity)

		cart
  end

  private

  def ensure_valid_quantity!(cart_item)
		if @cart_params[:quantity].to_i <= 0
			cart_item.errors.add(:quantity, "must be greater than 0")
			raise ActiveRecord::RecordInvalid, cart_item
		end
	end
end