# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.decimal :payment_amount
      t.datetime :payment_date

      t.timestamps
    end
  end
end
