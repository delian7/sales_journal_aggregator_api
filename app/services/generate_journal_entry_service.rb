# frozen_string_literal: true

class GenerateJournalEntryService
  def initialize(month, orders)
    @month = month
    @orders = orders
  end

  def call
    total_revenue = @orders.sum(&:total_sales).to_f.round(2)
    total_shipping = @orders.sum(&:total_shipping).to_f.round(2)
    total_taxes = @orders.sum(&:total_taxes).to_f.round(2)
    total_received = @orders.sum { |o| o.payments.sum(&:payment_amount) }.to_f.round(2)

    {
      month: @month.strftime("%m/%Y"),
      accounts_receivable_orders: {
        debit: total_revenue,
        credit: 0,
        description: "Cash expected for orders"
      },
      revenue: {
        debit: 0,
        credit: total_revenue,
        description: "Revenue for orders"
      },
      accounts_receivable_shipping: {
        debit: total_shipping,
        credit: 0,
        description: "Cash expected for shipping on orders"
      },
      shipping_revenue: {
        debit: 0,
        credit: total_shipping,
        description: "Revenue for shipping"
      },
      accounts_receivable_taxes: {
        debit: total_taxes,
        credit: 0,
        description: "Cash expected for taxes"
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
      },
      accounts_receivable_settled: {
        debit: 0,
        credit: total_received,
        description: "Removal of expectation of cash"
      }
    }
  end
end