require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    xit 'routes to #show' do
      expect(get: '/cart').to route_to('carts#show')
    end

    it 'routes to #create' do
      expect(post: '/cart').to route_to('carts#create')
    end

    xit 'routes to #add_item via POST' do
      expect(post: '/cart/add_item').to route_to('carts#add_item')
    end
  end
end 
