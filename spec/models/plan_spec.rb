require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price_cents) }
    it { is_expected.to validate_presence_of(:interval) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:subscriptions).dependent(:restrict_with_error) }
  end
end