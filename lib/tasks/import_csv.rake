# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import orders and payments from CSV"
  task orders_and_payments: :environment do
    file_path = ENV.fetch("FILE_PATH", nil)
    unless file_path
      puts "Please provide a file path using FILE_PATH environment variable"
      exit 1
    end

    successfully_imported = 0
    csv_file_path = Rails.root.join("data.csv")
    CSV.foreach(csv_file_path, headers: true) do |row|
      ActiveRecord::Base.transaction do
        order = Order.create!(
          external_order_id: row["order_id"],
          ordered_at: row["ordered_at"],
          item_type: row["item_type"],
          price_per_item: row["price_per_item"],
          quantity: row["quantity"],
          shipping: row["shipping"],
          tax_rate: row["tax_rate"]
        )

        # Create payments
        if row["payment_1_id"].present?
          Payment.create!(
            payment_id: row["payment_1_id"],
            payment_amount: row["payment_1_amount"],
            payment_date: row["ordered_at"],
            order: order
          )
        end

        if row["payment_2_id"].present?
          Payment.create!(
            payment_id: row["payment_2_id"],
            payment_amount: row["payment_2_amount"],
            payment_date: row["ordered_at"],
            order: order
          )
        end

        successfully_imported += 1
      end
    end

    puts "Successfully imported #{successfully_imported} orders and payments" unless Rails.env.test?
  rescue StandardError => e
    Rails.logger.error "Error: #{e.message}"
    puts "Error: #{e.message}"
  end
end
