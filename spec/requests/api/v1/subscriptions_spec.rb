require 'rails_helper'

RSpec.describe "Api::V1::Subscriptions", type: :request do
  let!(:customer) { Customer.create!(name: 'Carlos Mota', email: 'carlos.api@example.com') }
  let!(:plan) { Plan.create!(name: 'Plano Pro', price_cents: 9900, interval: :monthly) }

  describe "POST /api/v1/subscriptions", :vcr do
    context "com parâmetros válidos" do
      let(:valid_params) do
        {
          subscription: {
            customer_id: customer.id,
            plan_id: plan.id,
            payment_method_id: 'tok_visa'
          }
        }
      end

      it "retorna HTTP 201 Created e gera a assinatura" do
        post "/api/v1/subscriptions", params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['stripe_subscription_id']).to be_present
      end
    end

    context "quando o cliente não existe" do
      let(:invalid_params) do
        {
          subscription: {
            customer_id: 999999,
            plan_id: plan.id,
            payment_method_id: 'tok_visa'
          }
        }
      end

      it "retorna HTTP 404 Not Found" do
        post "/api/v1/subscriptions", params: invalid_params

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end