class CartsController < ApplicationController
  include ActionController::Cookies

  def create
    begin
      @cart = CartManagerService.new(session: session, cart_params: cart_params).call
    rescue ActiveRecord::RecordInvalid => e
      return render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
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
