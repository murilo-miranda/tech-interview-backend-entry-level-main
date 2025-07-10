FactoryBot.define do
  factory :product, class: 'Product' do
    name { Faker::Commerce.product_name }
    price { Faker::Commerce.price(range: 1.0..100.0) }
  end
end