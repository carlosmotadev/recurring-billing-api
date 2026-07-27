FactoryBot.define do
  factory :subscription do
    customer { nil }
    plan { nil }
    status { 1 }
    stripe_subscription_id { "MyString" }
    current_period_end { "2026-07-27 11:34:00" }
  end
end
