# frozen_string_literal: true

class AddItemTypeToOrder < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :item_type, :string
  end
end
