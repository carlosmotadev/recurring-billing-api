class Invoice < ApplicationRecord
  belongs_to :subscription

  enum :status, { pending: 0, paid: 1, failed: 2 }
end
