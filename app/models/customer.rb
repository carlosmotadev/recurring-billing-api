class Customer < ApplicationRecord
  has_many :subscriptions, dependent: :destroy

  validates :name, :email, presence: true
end