require 'swagger_helper'

RSpec.describe 'Api::V1::Subscriptions', type: :request do
  path '/api/v1/subscriptions' do
    post 'Cria uma nova assinatura recorrente' do
      tags 'Subscriptions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :subscription, in: :body, schema: {
        type: :object,
        properties: {
          subscription: {
            type: :object,
            properties: {
              customer_id: { type: :integer, example: 1 },
              plan_id: { type: :integer, example: 2 },
              payment_method_id: { type: :string, example: 'tok_visa' }
            },
            required: %w[customer_id plan_id payment_method_id]
          }
        }
      }

      response '201', 'Assinatura criada com sucesso', vcr: true do
        let(:customer) { Customer.create!(name: 'Carlos Mota', email: 'carlos@example.com') }
        let(:plan) { Plan.create!(name: 'Plano Pro', price_cents: 9900, interval: :monthly) }
        let(:subscription) do
          {
            subscription: {
              customer_id: customer.id,
              plan_id: plan.id,
              payment_method_id: 'tok_visa'
            }
          }
        end

        run_test!
      end
    end
  end
end