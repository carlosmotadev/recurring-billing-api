FactoryBot.define do
  factory :customer do
    name { "MyString" }
    email { "MyString" }
    document_number { "MyString" }
    stripe_customer_id { "MyString" }
  end
end
