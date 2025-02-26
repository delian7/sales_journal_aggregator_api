# frozen_string_literal: true

class AddPaymentIdToPayments < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :payment_id, :string
  end
end
