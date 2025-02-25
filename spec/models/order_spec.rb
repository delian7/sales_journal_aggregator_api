# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    it { should validate_presence_of(:price_per_item) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:shipping) }
    it { should validate_presence_of(:tax_rate) }
    it { should validate_presence_of(:ordered_at) }
  end

  describe "calculations" do
    let(:order) { Order.new(price_per_item: 10.0, quantity: 2, shipping: 5.0, tax_rate: 0.1) }

    it "calculates the total sales" do
      expect(order.total_sales).to eq(20.0)
    end

    it "calculates the total shipping" do
      expect(order.total_shipping).to eq(5.0)
    end

    it "calculates the total taxes" do
      expect(order.total_taxes).to eq(2.0)
    end
  end
end
