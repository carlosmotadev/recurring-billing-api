require 'ostruct'

module Stripe
  class CreateSubscriptionService
    def initialize(customer:, plan:, payment_method_id:)
      @customer = customer
      @plan = plan
      @payment_method_id = payment_method_id
    end

    def call
      stripe_customer = ensure_stripe_customer
      attach_payment_method(stripe_customer.id) if @payment_method_id.present?

      stripe_sub = ::Stripe::Subscription.create({
        customer: stripe_customer.id,
        items: [{ price: fetch_or_create_stripe_price_id }],
        expand: ['latest_invoice.payment_intent']
      })

      # Extrai o timestamp de término do período
      period_end_timestamp = stripe_sub[:current_period_end] || stripe_sub.items.data.first&.current_period_end

      subscription = ::Subscription.create!(
        customer: @customer,
        plan: @plan,
        stripe_subscription_id: stripe_sub.id,
        status: stripe_sub.status == 'active' ? :active : :pending,
        current_period_end: period_end_timestamp ? Time.at(period_end_timestamp) : 1.month.from_now
      )

      invoice_data = stripe_sub[:latest_invoice]
      if invoice_data.present?
        # Se veio expandido ou como Hash/Object
        amount = invoice_data.respond_to?(:amount_due) ? invoice_data.amount_due : invoice_data[:amount_due]
        paid = invoice_data.respond_to?(:paid) ? invoice_data.paid : invoice_data[:paid]
        invoice_id = invoice_data.respond_to?(:id) ? invoice_data.id : invoice_data[:id]

        ::Invoice.create!(
          subscription: subscription,
          amount_cents: amount || @plan.price_cents,
          status: paid ? :paid : :pending,
          stripe_invoice_id: invoice_id,
          paid_at: paid ? Time.current : nil
        )
      end

      OpenStruct.new(success?: true, subscription: subscription, errors: nil)
    rescue ::Stripe::StripeError => e
      OpenStruct.new(success?: false, subscription: nil, errors: e.message)
    end

    private

    def ensure_stripe_customer
      if @customer.stripe_customer_id.present?
        ::Stripe::Customer.retrieve(@customer.stripe_customer_id)
      else
        stripe_customer = ::Stripe::Customer.create(
          email: @customer.email,
          name: @customer.name
        )
        @customer.update!(stripe_customer_id: stripe_customer.id)
        stripe_customer
      end
    end

    def attach_payment_method(stripe_customer_id)
      if @payment_method_id.start_with?('tok_')
        ::Stripe::Customer.create_source(
          stripe_customer_id,
          { source: @payment_method_id }
        )
      else
        ::Stripe::PaymentMethod.attach(@payment_method_id, { customer: stripe_customer_id })
        ::Stripe::Customer.update(stripe_customer_id, {
          invoice_settings: { default_payment_method: @payment_method_id }
        })
      end
    end

    def fetch_or_create_stripe_price_id
      return @plan.stripe_price_id if @plan.stripe_price_id.present?

      stripe_interval = case @plan.interval.to_sym
                        when :monthly then 'month'
                        when :yearly  then 'year'
                        else @plan.interval
                        end

      stripe_product = ::Stripe::Product.create(name: @plan.name)
      stripe_price = ::Stripe::Price.create(
        unit_amount: @plan.price_cents,
        currency: 'brl',
        recurring: { interval: stripe_interval },
        product: stripe_product.id
      )

      @plan.update!(stripe_price_id: stripe_price.id)
      stripe_price.id
    end
  end
end