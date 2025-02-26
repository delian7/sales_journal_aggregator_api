# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    payment_amount { Faker::Commerce.price(range: 5.0..100.0) }
    payment_date { Faker::Date.between(from: 1.year.ago, to: Date.today) }
    payment_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    association :order
  end
end
