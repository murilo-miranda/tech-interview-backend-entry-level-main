class CartsController < ApplicationController
  include ActionController::Cookies

  def create
    begin
      @cart = CartManagerService.call(session: session, cart_params: cart_params)
    rescue ActiveRecord::RecordInvalid => e
      return render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    render json: json_response, status: :ok
  end

  def show
    begin
      @cart = CartManagerService.find_cart(session: session)
    rescue ActiveRecord::RecordNotFound => e
      return render json: { errors: "Session not found, please create a new cart" }, status: :not_found
    end

    render json: json_response, status: :ok
  end

  def add_item
    begin
      @cart = CartManagerService.update(session: session, cart_params: cart_params)
    rescue ActiveRecord::RecordNotFound => e
      if e.model == "Cart"
        return render json: { errors: "Session not found, please create a new cart" }, status: :not_found
      end

      return render json: { errors: e }, status: :not_found
    end

    render json: json_response, status: :ok
  end

  def remove_item
    begin
      @cart = CartManagerService.remove_item(session: session, cart_params: cart_params)
    rescue ActiveRecord::RecordNotFound => e
      if e.model == "Cart"
        return render json: { errors: "Session not found, please create a new cart" }, status: :not_found
      end

      return render json: { errors: e }, status: :not_found
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
