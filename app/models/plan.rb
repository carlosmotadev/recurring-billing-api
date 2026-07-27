class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error

  # Sintaxe atualizada para Rails 7.1 / 8.x:
  enum :interval, { monthly: 0, yearly: 1 }

  validates :name, :price_cents, :interval, presence: true
  validates :price_cents, numericality: { greater_than: 0 }
end