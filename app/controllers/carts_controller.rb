class CartsController < ApplicationController
  include ActionController::Cookies

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  def create
    @cart = CartManagerService.call(session: session, cart_params: cart_params)
    render json: json_response, status: :ok
  end

  def show
    @cart = CartManagerService.find_cart(session: session)
    render json: json_response, status: :ok
  end

  def add_item
    @cart = CartManagerService.update(session: session, cart_params: cart_params)
    render json: json_response, status: :ok
  end

  def remove_item
    @cart = CartManagerService.remove_item(session: session, cart_params: cart_params)
    render json: json_response, status: :ok
  end

  private
  
  def json_response
    CartPresenter.new(@cart).as_json
  end

  def cart_params
    params.permit(:product_id, :quantity).merge(cart: @cart)
  end

  def render_not_found(error)
    if error.model == "Cart"
      render json: { errors: "Session not found, please create a new cart" }, status: :not_found
    elsif error.model == "CartItem"
      render json: { errors: "The product does not exist in the cart" }, status: :not_found
    else
      render json: { errors: error }, status: :not_found
    end
  end

  def render_record_invalid(error)
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end
end
