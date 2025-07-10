class CartsController < ApplicationController
  include ActionController::Cookies

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  before_action :set_action_name

  def create
    @cart = CartManagerService.call(session: session, cart_params: cart_params, action: @current_action)
    render_cart_info
  end

  def show
    @cart = CartManagerService.call(session: session, cart_params: {}, action: @current_action)
    render_cart_info
  end

  def add_item
    @cart = CartManagerService.call(session: session, cart_params: cart_params, action: @current_action)
    render_cart_info
  end

  def remove_item
    @cart = CartManagerService.call(session: session, cart_params: cart_params, action: @current_action)
    render_cart_info
  end

  private
  
  def render_cart_info
    render json: CartPresenter.new(@cart).as_json, status: :ok
  end

  def cart_params
    params.permit(:product_id, :quantity)
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

  def set_action_name
    @current_action = action_name
  end
end
