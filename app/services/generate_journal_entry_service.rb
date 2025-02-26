# frozen_string_literal: true

class GenerateJournalEntryService
  def initialize(month, orders)
    @month = month
    @orders = orders
  end

  def call
    total_revenue = @orders.sum(&:total_sales).to_f
    total_shipping = @orders.sum(&:total_shipping).to_f
    total_taxes = @orders.sum(&:total_taxes).to_f
    total_received = @orders.sum { |o| o.payments.sum(&:payment_amount) }.to_f

    {
      month: @month.strftime("%m/%Y"),
      accounts_receivable: {
        debit: total_revenue + total_shipping + total_taxes,
        credit: total_received,
        description: "Cash expected for orders, shipping, and taxes"
      },
      revenue: {
        debit: 0,
        credit: total_revenue,
        description: "Revenue for orders"
      },
      shipping_revenue: {
        debit: 0,
        credit: total_shipping,
        description: "Revenue for shipping"
      },
      sales_tax_payable: {
        debit: 0,
        credit: total_taxes,
        description: "Cash to be paid for sales tax"
      },
      cash: {
        debit: total_received,
        credit: 0,
        description: "Cash received"
      }
    }
  end
end
