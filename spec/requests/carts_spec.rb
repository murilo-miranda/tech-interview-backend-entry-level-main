require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /cart" do
    let(:headers) { { 'ACCEPT' => 'application/json' } }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let(:quantity) { 1 }
    let(:params) {
      {
        "product_id": product.id,
        "quantity": quantity
      }
    }

    describe 'with valid parameters' do
      context 'when cookie session was not present' do
        it 'creates a cookie session' do
          post '/cart', params: params, headers: headers

          cookie_session = response.headers['Set-Cookie']
          expect(cookie_session).to include("_store_session")
        end
      end

      context 'when cookie session was present' do
        let!(:product2) { Product.create(name: "Test Product 2", price: 7.0) }
        let(:second_params) {
          {
            "product_id": product2.id,
            "quantity": quantity
          }
        }

        it 'do not creates a new cart' do
          post '/cart', params: params
          valid_session_cookie = response.headers['Set-Cookie']

          post '/cart', params: second_params, headers: { 'Cookie': valid_session_cookie }
          expect { post '/cart', params: params, headers: headers }.not_to change(Cart, :count)
        end

        it 'creates a new cart item' do
          post '/cart', params: params
          valid_session_cookie = response.headers['Set-Cookie']

          expect { post '/cart', params: second_params, headers: { 'Cookie': valid_session_cookie } }.to change(CartItem, :count).by(1)
        end

        it 'returns cart and product info in json format with status code 200' do
          post '/cart', params: params
          valid_session_cookie = response.headers['Set-Cookie']
          cart_created_from_prev_session = Cart.last

          expected_response = {
            "id": cart_created_from_prev_session.id,
            "products": [
              {
                "id": product.id,
                "name": product.name,
                "quantity": quantity,
                "unit_price": product.price.to_f,
                "total_price": (product.price * 1).to_f
              },
              {
                "id": product2.id,
                "name": product2.name,
                "quantity": quantity,
                "unit_price": product2.price.to_f,
                "total_price": (product2.price * 1).to_f
              }
            ],
            "total_price": (product.price * 1 + product2.price * 1).to_f
          }
          
          post '/cart', params: second_params, headers: { 'Cookie': valid_session_cookie }

          parsed_body = JSON.parse(response.body, symbolize_names: true)
          expect(parsed_body).to eq(expected_response)
          expect(response).to have_http_status(:ok)
        end

        context 'and is trying to add the same product' do
          it 'returns error info in json format with status code 422' do
            post '/cart', params: params
            valid_session_cookie = response.headers['Set-Cookie']
            cart_created_from_prev_session = Cart.last

            post '/cart', params: params, headers: headers.merge('Cookie': valid_session_cookie)

            parsed_body = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_body).to eq({ "errors": ["Product already exists in cart"] })
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when the cart does not exist' do
        let(:cart_item) { CartItem.create(cart: Cart.last, product: product, quantity: quantity) }
        let(:expected_response) {
          {
            "id": Cart.last.id,
            "products": [{
              "id": product.id,
              "name": product.name,
              "quantity": quantity,
              "unit_price": product.price.to_f,
              "total_price": (product.price * 1).to_f
            }],
            "total_price": (product.price * 1).to_f
          }
        }

        it 'creates a new cart' do
          expect { post '/cart', params: params, headers: headers }.to change(Cart, :count).by(1)
        end

        it 'creates a new cart item' do
          expect { post '/cart', params: params, headers: headers }.to change(CartItem, :count).by(1)
        end

        it 'returns cart and product info in json format with status code 200' do
          post '/cart', params: params, headers: headers

          parsed_body = JSON.parse(response.body, symbolize_names: true)
          expect(parsed_body).to eq(expected_response)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe 'with invalid parameters' do
      let(:expected_response) {
        {
          "errors": ["Quantity must be greater than 0"]
        }
      }

      context 'when numericality of product quantity is negative' do
        context 'and cart does not exist' do
          let(:quantity) { -1 }

          it 'do not creates a new cart' do
            expect { post '/cart', params: params }.not_to change(Cart, :count)
          end

          it 'do not creates a new cart association' do
            expect { post '/cart', params: params }.not_to change(CartItem, :count)
          end

          it 'returns error info in json format with status code 422' do
            post '/cart', params: params

            parsed_body = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_body).to include(expected_response)
          end
        end
      end

      context 'when numericality of product quantity is zero' do
        context 'and cart does not exist' do
          let(:quantity) { 0 }

          it 'do not creates a new cart' do
            expect { post '/cart', params: params }.not_to change(Cart, :count)
          end

          it 'do not creates a new cart association' do
            expect { post '/cart', params: params }.not_to change(CartItem, :count)
          end

          it 'returns error info in json format with status code 422' do
            post '/cart', params: params

            parsed_body = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_body).to include(expected_response)
          end
        end
      end

      context 'when numericality of product quantity is not a number' do
        context 'and cart does not exist' do
          let(:quantity) { "a" }
          let(:expected_response) {
            {
              "errors": ["Quantity is not a number"]
            }
          }

          it 'do not creates a new cart' do
            expect { post '/cart', params: params }.not_to change(Cart, :count)
          end

          it 'do not creates a new cart association' do
            expect { post '/cart', params: params }.not_to change(CartItem, :count)
          end

          it 'returns error info in json format with status code 422' do
            post '/cart', params: params

            parsed_body = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_body).to include(expected_response)
          end
        end
      end

      context 'when product does not exist' do
        context 'and cart does not exist' do
          let(:quantity) { 1 }
          let(:params) {
            {
              "product_id": 999_999,
              "quantity": quantity
            }
          }
          let(:expected_response) {
            {
              "errors": ["Product must exist"]
            }
          }

          it 'do not creates a new cart' do
            expect { post '/cart', params: params }.not_to change(Cart, :count)
          end

          it 'do not creates a new cart association' do
            expect { post '/cart', params: params }.not_to change(CartItem, :count)
          end

          it 'returns error info in json format with status code 422' do
            post '/cart', params: params

            parsed_body = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_body).to include(expected_response)
          end
        end
      end
    end
  end
    
  describe "POST /add_item" do
    let(:cart) { Cart.create(total_price: 0.0) }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when session is present' do
      context 'when the product already is in the cart' do
        let(:expected_response) {
          {
            "id": Cart.last.id,
            "products": [{
              "id": product.id,
              "name": product.name,
              "quantity": 3,
              "unit_price": product.price.to_f,
              "total_price": (product.price * 3).to_f
            }],
            "total_price": (product.price * 3).to_f
          }
        }


        before do
          post '/cart', params: { product_id: product.id, quantity: 1 }
          @cookie_session = response.headers['Set-Cookie']
        end
        
        subject do
          post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, headers: { 'Cookie': @cookie_session }, as: :json
          post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, headers: { 'Cookie': @cookie_session }, as: :json
        end

        it 'updates the quantity of the existing item in the cart' do
          expect {
            subject
          }.to change {
            CartItem.find_by(cart: Cart.last, product: product).reload.quantity
          }.by(2)
        end

        it 'returns the updated cart in json format with status code 200' do
          subject
          parsed_body = JSON.parse(response.body, symbolize_names: true)
          expect(parsed_body).to include(expected_response)
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the product is not in the cart' do
        let(:params) {
          {
            "product_id": 999_999,
            "quantity": 1
          }
        }
        let(:expected_response) {
          {
            "errors": "Couldn't find Product with 'id'=999999"
          }
        }

        it 'returns error info in json format with status code 422' do
          post '/cart', params: { product_id: product.id, quantity: 1 }
          valid_session_cookie = response.headers['Set-Cookie']

          post '/cart/add_item', params: params, headers: { 'Cookie': valid_session_cookie, 'ACCEPT': 'application/json' }

          parsed_body = JSON.parse(response.body, symbolize_names: true)  
          expect(parsed_body).to include(expected_response)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when session is not present' do
      let(:expected_response) {
        {
          "errors": "Session not found, please create a new cart"
        }
      }

      it 'returns error info in json format with status code 422' do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, headers: headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_body).to include(expected_response)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /cart" do
    let(:headers) { { 'ACCEPT' => 'application/json' } }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let(:quantity) { 1 }
    let(:params) {
      {
        "product_id": product.id,
        "quantity": quantity
      }
    }

    context 'when session is not present' do
      let(:expected_response) {
        {
          "errors": "Session not found, please create a new cart"
        }
      }

      it 'returns error info in json format with status code 422' do
        get '/cart', headers: headers

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_body).to include(expected_response)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when session is present' do
      let(:expected_response) {
        {
          "id": Cart.last.id,
          "products": [{
            "id": product.id,
            "name": product.name,
            "quantity": quantity,
            "unit_price": product.price.to_f,
            "total_price": (product.price * 1).to_f
          }],
          "total_price": (product.price * 1).to_f
        }
      }
      
      it 'returns the cart info with status code 200' do
        post '/cart', params: params
        valid_session_cookie = response.headers['Set-Cookie']

        get '/cart', headers: headers.merge('Cookie': valid_session_cookie)

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_body).to eq(expected_response)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
