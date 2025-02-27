# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateJournalEntryService, type: :service do
  describe "#call" do
    let(:month) { DateTime.now.beginning_of_month }
    let(:orders) { create_list(:order_with_payments, 3) }
    let(:service) { described_class.new(month, orders) }

    it "calculates the total revenue" do
      result = service.call
      total_revenue = orders.sum { |order| order.price_per_item * order.quantity }.round(2)

      expect(result[:revenue][:credit]).to be_within(0.01).of(total_revenue)
      expect(result[:revenue][:debit]).to eq(0)
    end

    it "calculates the total shipping revenue separately" do
      result = service.call
      total_shipping = orders.sum(&:shipping).round(2)

      expect(result[:shipping_revenue][:credit]).to be_within(0.01).of(total_shipping)
      expect(result[:shipping_revenue][:debit]).to eq(0)
    end

    it "calculates the total sales tax payable separately" do
      result = service.call
      total_taxes = orders.sum { |order| (order.price_per_item * order.quantity * order.tax_rate).round(2) }

      expect(result[:sales_tax_payable][:credit]).to be_within(0.01).of(total_taxes)
      expect(result[:sales_tax_payable][:debit]).to eq(0)
    end

    it "calculates the total cash received" do
      result = service.call
      total_received = orders.sum { |order| order.payments.sum(&:payment_amount) }.round(2)

      expect(result[:cash][:debit]).to be_within(0.01).of(total_received)
      expect(result[:cash][:credit]).to eq(0)
    end

    it "ensures all debits match all credits" do
      result = service.call

      total_debits = result
                     .except(:month)
                     .values
                     .sum { |entry| entry[:debit] }

      # total_credits = result.values.sum { |entry| entry[:credit] }
      total_credits = result
                      .except(:month)
                      .values
                      .sum { |entry| entry[:credit] }

      expect(total_debits).to be_within(0.01).of(total_credits)
    end
  end
end
