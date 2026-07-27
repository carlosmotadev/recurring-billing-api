class Subscription < ApplicationRecord
  belongs_to :customer
  belongs_to :plan
  has_many :invoices, dependent: :destroy

  enum :status, { pending: 0, active: 1, past_due: 2, canceled: 3 }
end
