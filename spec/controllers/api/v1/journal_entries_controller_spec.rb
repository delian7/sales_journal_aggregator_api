# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::JournalEntriesController, type: :request do
  let(:user) { create(:user, password: "password") }
  let!(:order1) { create(:order_with_payments, ordered_at: DateTime.new(2023, 1, 15)) }
  let!(:order2) { create(:order_with_payments, ordered_at: DateTime.new(2023, 1, 20)) }
  let!(:order3) { create(:order_with_payments, ordered_at: DateTime.new(2023, 2, 10)) }

  describe "GET #index" do
    context "when user is not authenticated" do
      before do
        get api_v1_journal_entries_path
      end

      it "returns a 401 Unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("You need to sign in or sign up before continuing.")
      end
    end

    context "when there are orders" do
      before do
        @auth_headers = auth_headers(user)
        get api_v1_journal_entries_path, headers: @auth_headers
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a list of months" do
        json_response = JSON.parse(response.body)
        expect(json_response["months"]).to be_present
        expect(json_response["months"].size).to eq(2)
      end

      it "returns the correct months" do
        json_response = JSON.parse(response.body)
        expect(json_response["months"]).to include("2023-02")
        expect(json_response["months"]).to include("2023-01")
      end
    end

    context "when there are no orders" do
      before do
        Order.destroy_all
        @auth_headers = auth_headers(user)
        get api_v1_journal_entries_path, headers: @auth_headers
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "returns an empty list of months" do
        json_response = JSON.parse(response.body)
        expect(json_response["months"]).to be_empty
      end
    end
  end

  describe "GET #show" do
    before do
      @auth_headers = auth_headers(user)
      @journal_entry = GenerateJournalEntryService.new(DateTime.new(2023, 1, 1), [order1, order2]).call
    end

    context "when user is not authenticated" do
      before do
        get show_api_v1_journal_entries_path(month: 1, year: 2023)
      end

      it "returns a 401 Unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("You need to sign in or sign up before continuing.")
      end
    end

    context "when journal entry exists" do
      before do
        get show_api_v1_journal_entries_path(month: 1, year: 2023), headers: @auth_headers
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the journal entry for the specified month and year" do
        json_response = JSON.parse(response.body)
        expect(json_response["journal_entry"]).to be_present
        expect(json_response["journal_entry"]["month"]).to eq("01/2023")
      end

      it "returns the correct journal entry data" do
        json_response = JSON.parse(response.body)
        expect(json_response["journal_entry"]["accounts_receivable"]).to be_present
        expect(json_response["journal_entry"]["revenue"]).to be_present
        expect(json_response["journal_entry"]["shipping_revenue"]).to be_present
        expect(json_response["journal_entry"]["sales_tax_payable"]).to be_present
        expect(json_response["journal_entry"]["cash"]).to be_present
        expect(json_response["journal_entry"]["accounts_receivable"]["debit"]).to be_present
        expect(json_response["journal_entry"]["accounts_receivable"]["credit"]).to be_present
        expect(json_response["journal_entry"]["revenue"]["credit"]).to be_present
        expect(json_response["journal_entry"]["shipping_revenue"]["credit"]).to be_present
        expect(json_response["journal_entry"]["sales_tax_payable"]["credit"]).to be_present
        expect(json_response["journal_entry"]["cash"]["debit"]).to be_present
      end

      context "when the cache is enabled" do
        it "returns a cached journal entry" do
          skip "Skipping since cache not enabled" if ENV["ENABLE_CACHING"].blank?

          expect(Rails.cache.exist?("journal_entry_2023_01")).to be_truthy
        end
      end
    end

    context "when journal entry does not exist" do
      before do
        get show_api_v1_journal_entries_path(month: 5, year: 2025), headers: @auth_headers
      end

      it "returns a 404 Not Found response" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Journal entry not found")
      end
    end
  end
end
