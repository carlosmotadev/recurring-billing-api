FactoryBot.define do
  factory :plan do
    name { "MyString" }
    price_cents { 1 }
    interval { 1 }
    stripe_price_id { "MyString" }
  end
end
