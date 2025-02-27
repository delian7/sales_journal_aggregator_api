# frozen_string_literal: true

class AddExternalOrderIdToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :external_order_id, :string
  end
end
