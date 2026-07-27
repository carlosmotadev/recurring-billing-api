require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to have_many(:invoices).dependent(:destroy) }
  end
end