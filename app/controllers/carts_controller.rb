class CartsController < ApplicationController
  include ActionController::Cookies

  def create
    cart_id = session[:cart_id]

    if cart_id.nil?
      begin
        ActiveRecord::Base.transaction do
          @cart = Cart.create!(total_price: 0)
          @cart_item = CartItem.create!(cart_params)
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
        return
      end

      session[:cart_id] = @cart.id
    else
      @cart = Cart.find(cart_id)
      begin
        @cart_item = CartItem.create!(cart_params)
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end
    end

    render json: json_response, status: :ok
  end

  private
  
  def json_response
    CartPresenter.new(@cart).as_json
  end

  def cart_params
    params.permit(:product_id, :quantity).merge(cart: @cart)
  end
end
