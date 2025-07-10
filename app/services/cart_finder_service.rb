class CartFinderService
  def initialize(**args)
    @session = args[:session]
  end

  def self.call(**args)
    new(**args).call
  end

  def call
    Cart.find(@session[:cart_id])
  end
end