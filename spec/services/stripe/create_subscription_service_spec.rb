require 'rails_helper'

RSpec.describe Stripe::CreateSubscriptionService, type: :service do
  let!(:customer) { Customer.create!(name: 'Carlos Mota', email: 'carlos.test@example.com') }
  let!(:plan) { Plan.create!(name: 'Plano Pro', price_cents: 9900, interval: :monthly) }
  let(:payment_method_id) { 'tok_visa' }

  subject do
    described_class.new(
      customer: customer,
      plan: plan,
      payment_method_id: payment_method_id
    )
  end

  describe '#call', :vcr do
    context 'com parâmetros válidos' do
      it 'cria a assinatura e a fatura com sucesso' do
        result = subject.call

        expect(result.success?).to be true
        expect(result.subscription).to be_persisted
        expect(result.subscription.stripe_subscription_id).to be_present
        expect(customer.reload.stripe_customer_id).to be_present
        expect(Invoice.where(subscription: result.subscription)).to exist
      end
    end

    context 'quando o cartão é recusado ou inválido' do
      let(:payment_method_id) { 'tok_chargeDeclined' }

      it 'retorna erro sem levantar exceção não tratada' do
        result = subject.call

        expect(result.success?).to be false
        expect(result.errors).to be_present
      end
    end
  end
end