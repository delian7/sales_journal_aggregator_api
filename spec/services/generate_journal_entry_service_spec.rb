require "rails_helper"

RSpec.describe GenerateJournalEntryService, type: :service do
  describe "#call" do
    let(:month) { DateTime.now.beginning_of_month }
    let(:orders) { create_list(:order_with_payments, 3) }
    let(:service) { described_class.new(month, orders) }

    it "calculates the total revenue" do
      result = service.call
      total_revenue = orders.sum { |order| order.price_per_item * order.quantity }
      expect(result[:revenue][:credit]).to eq(total_revenue.round(2))
      expect(result[:revenue][:debit]).to eq(0)
    end

    it "calculates the total shipping" do
      result = service.call
      total_shipping = orders.sum(&:shipping)
      expect(result[:shipping_revenue][:credit]).to eq(total_shipping.round(2))
      expect(result[:shipping_revenue][:debit]).to eq(0)
    end

    it "calculates the total taxes" do
      result = service.call
      total_taxes = orders.sum { |order| order.price_per_item * order.quantity * order.tax_rate }
      expect(result[:sales_tax_payable][:credit]).to eq(total_taxes.round(2))
      expect(result[:sales_tax_payable][:debit]).to eq(0)
    end

    it "calculates the total received payments" do
      result = service.call
      total_received = orders.sum { |order| order.payments.sum(&:payment_amount) }
      expect(result[:cash][:debit]).to eq(total_received.round(2))
      expect(result[:cash][:credit]).to eq(0)
    end

    it "calculates the accounts receivable" do
      result = service.call
      total_revenue = orders.sum(&:total_sales)
      total_shipping = orders.sum(&:total_shipping)
      total_taxes = orders.sum(&:total_taxes)
      total_received = orders.sum { |o| o.payments.sum(&:payment_amount) }
      expect(result[:accounts_receivable][:debit].round(2)).to eq((total_revenue + total_shipping + total_taxes).round(2))
      expect(result[:accounts_receivable][:credit]).to eq(total_received.round(2))
    end
  end
end
