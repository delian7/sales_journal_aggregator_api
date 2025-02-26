# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    price_per_item { Faker::Commerce.price(range: 5.0..100.0) }
    quantity { Faker::Number.between(from: 1, to: 10) }
    shipping { Faker::Commerce.price(range: 1.0..20.0) }
    tax_rate { Faker::Number.decimal(l_digits: 0, r_digits: 2) }
    external_order_id { Faker::Number.unique.number(digits: 10) }
    ordered_at { Faker::Date.between(from: 1.year.ago, to: Date.today) }
    item_type { Faker::Commerce.product_name }

    factory :order_with_payments do
      after(:create) do |order|
        create_list(:payment, 2, order: order)
      end
    end
  end
end
