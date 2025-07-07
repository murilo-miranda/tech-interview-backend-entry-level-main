FactoryBot.define do
  factory :shopping_cart, class: 'Cart' do
    total_price { 0 }

    trait :abandoned do
      status { 'abandoned' }
    end

    trait :inactivity_of_3_hours do
      last_interaction_at { 3.hours.ago }
    end

    trait :inactivity_of_7_days do
      last_interaction_at { 7.days.ago }
    end
  end
end