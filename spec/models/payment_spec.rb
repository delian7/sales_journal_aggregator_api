# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "validations" do
    it { should validate_presence_of(:payment_id) }
    it { should validate_presence_of(:payment_amount) }
    it { should validate_presence_of(:payment_date) }
    it { should validate_presence_of(:order_id) }
  end

  describe "associations" do
    it { should belong_to(:order) }
  end
end
