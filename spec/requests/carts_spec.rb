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
    
  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      xit 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
