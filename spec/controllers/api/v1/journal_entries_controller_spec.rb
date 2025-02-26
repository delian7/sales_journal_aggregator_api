# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::JournalEntriesController, type: :request do
  describe "GET #index" do
    let(:user) { create(:user, password: "password") }
    let!(:order1) { create(:order_with_payments, ordered_at: DateTime.new(2023, 1, 15)) }
    let!(:order2) { create(:order_with_payments, ordered_at: DateTime.new(2023, 1, 20)) }
    let!(:order3) { create(:order_with_payments, ordered_at: DateTime.new(2023, 2, 10)) }

    before do
      @auth_headers = auth_headers(user)
      get api_v1_journal_entries_path, headers: @auth_headers
    end

    it "returns a successful response" do
      expect(response).to have_http_status(:ok)
    end

    it "returns the correct journal entries for the specified month and year" do
      json_response = JSON.parse(response.body)
      expect(json_response["journal_entry"].size).to eq(2)

      journal_entry = json_response["journal_entry"].first
      expect(journal_entry["month"]).to eq("01/2023")

      total_revenue = order1.total_sales + order2.total_sales
      total_shipping = order1.total_shipping + order2.total_shipping
      total_taxes = order1.total_taxes + order2.total_taxes
      total_received = order1.payments.sum(&:payment_amount) + order2.payments.sum(&:payment_amount)

      expect(journal_entry["accounts_receivable"]["debit"].round(2)).to eq((total_revenue + total_shipping + total_taxes).round(2))
      expect(journal_entry["accounts_receivable"]["credit"].round(2)).to eq(total_received.round(2))
      expect(journal_entry["revenue"]["credit"].round(2)).to eq(total_revenue.round(2))
      expect(journal_entry["shipping_revenue"]["credit"].round(2)).to eq(total_shipping.round(2))
      expect(journal_entry["sales_tax_payable"]["credit"].round(2)).to eq(total_taxes.round(2))
      expect(journal_entry["cash"]["debit"].round(2)).to eq(total_received.round(2))
    end
  end
end
