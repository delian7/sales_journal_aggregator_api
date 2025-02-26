# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "import:orders_and_payments", type: :task do
  before(:all) do
    Rake.application.rake_require("tasks/import_csv")
    Rake::Task.define_task(:environment)
    ENV["FILE_PATH"] = Rails.root.join("spec/fixtures/files/data.csv").to_s
  end

  let(:task) { Rake::Task["import:orders_and_payments"] }

  before do
    allow(Rails.root).to receive(:join).and_return("spec/fixtures/files/data.csv")
  end

  it "imports orders and payments from CSV" do
    expect { task.invoke }.to change { Order.count }.by(1).and change { Payment.count }.by(2)

    order = Order.first
    expect(order.external_order_id).to eq("1")
    expect(order.price_per_item).to eq(10.0)
    expect(order.quantity).to eq(2)
    expect(order.shipping).to eq(5.0)
    expect(order.tax_rate).to eq(0.1)
    expect(order.ordered_at).to eq(DateTime.parse("2025-02-25"))
    expect(order.item_type).to eq("item_type_1")

    payment1 = Payment.find_by(payment_id: "payment_1")
    expect(payment1.payment_amount).to eq(15.0)
    expect(payment1.payment_date).to eq(DateTime.parse("2025-02-25"))
    expect(payment1.order).to eq(order)

    payment2 = Payment.find_by(payment_id: "payment_2")
    expect(payment2.payment_amount).to eq(20.0)
    expect(payment2.payment_date).to eq(DateTime.parse("2025-02-25"))
    expect(payment2.order).to eq(order)
  end
end
