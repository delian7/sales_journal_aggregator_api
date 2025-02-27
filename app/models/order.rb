# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :payments, dependent: :destroy

  validates :external_order_id, presence: true, uniqueness: true
  validates :price_per_item, :quantity, :shipping, :tax_rate, :ordered_at, :item_type, presence: true
  validates :price_per_item, :quantity, :shipping, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

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
