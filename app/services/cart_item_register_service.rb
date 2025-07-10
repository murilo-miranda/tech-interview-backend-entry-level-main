class CartItemRegisterService
  def initialize(**args)
    @session = args[:session]
    @cart_params = args[:cart_params]
  end

  def self.call(**args)
    new(**args).call
  end

  def call
    ActiveRecord::Base.transaction do
			cart = load_or_create_cart
			CartItem.create!(@cart_params.merge(cart: cart))
			cart
		end
  end

	private

  def load_or_create_cart
    @session[:cart_id] ||= Cart.create!(total_price: 0.0).id
    Cart.find(@session[:cart_id])
  end
end