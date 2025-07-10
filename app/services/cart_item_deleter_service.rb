class CartItemDeleterService
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
		cart_item.destroy!
		cart
  end
end