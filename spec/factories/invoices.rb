FactoryBot.define do
  factory :invoice do
    subscription { nil }
    amount_cents { 1 }
    status { 1 }
    stripe_invoice_id { "MyString" }
    paid_at { "2026-07-27 11:34:10" }
  end
end
