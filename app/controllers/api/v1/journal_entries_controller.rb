# frozen_string_literal: true

module Api
  module V1
    class JournalEntriesController < ApplicationController
      def index
        orders_by_month = Order.includes(:payments).group_by { |o| o.ordered_at.beginning_of_month }

        journal_entries = orders_by_month.map do |month, orders|
          GenerateJournalEntryService.new(month, orders).call
        end

        render json: { journal_entry: journal_entries }, status: :ok
      end
    end
  end
end
