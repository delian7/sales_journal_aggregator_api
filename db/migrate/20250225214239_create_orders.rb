# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.decimal :price_per_item
      t.integer :quantity
      t.decimal :shipping
      t.decimal :tax_rate
      t.datetime :ordered_at

      t.timestamps
    end
  end
end
