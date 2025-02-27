# frozen_string_literal: true

module Api
  module V1
    class JournalEntriesController < ApplicationController
      before_action :authenticate_user!

      def index
        months = Order
                 .select("DISTINCT strftime('%Y-%m', ordered_at) AS month")
                 .order("month DESC")
                 .map(&:month)

        render json: { months: months }, status: :ok
      end

      def show
        month = params[:month]
        year = params[:year]

        date = DateTime.new(year.to_i, month.to_i)
        orders = Order.where("strftime('%Y-%m', ordered_at) = ?", date.strftime("%Y-%m"))

        raise ActiveRecord::RecordNotFound if orders.empty?

        # cache this result for 1 hour
        # Use a unique cache key based on the date
        # and the orders to ensure that the cache is invalidated
        # when the orders change.
        cache_key = "journal_entry_#{date.strftime('%Y_%m')}"
        journal_entry = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          GenerateJournalEntryService.new(date, orders).call
        end

        if journal_entry
          render json: { journal_entry: journal_entry }, status: :ok
        else
          render json: { error: "Journal entry not found" }, status: :not_found
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Journal entry not found" }, status: :not_found
      rescue ArgumentError => e
        render json: { error: e.message }, status: :bad_request
      rescue StandardError => e
        Rails.logger.error("Error fetching journal entry: #{e.message}")
        render json: { error: "An error occurred while fetching the journal entry" }, status: :internal_server_error
      end
    end
  end
end
