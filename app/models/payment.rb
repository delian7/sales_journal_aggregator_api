# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :order

  validates :payment_amount, :payment_date, :order_id, presence: true
end
