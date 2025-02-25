# frozen_string_literal: true

class Order < ApplicationRecord
  validates :price_per_item, :quantity, :shipping, :tax_rate, :ordered_at, presence: true

  def total_sales
    price_per_item * quantity
  end

  def total_shipping
    shipping
  end

  def total_taxes
    total_sales * tax_rate
  end
end
