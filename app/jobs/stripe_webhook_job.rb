class StripeWebhookJob
  include Sidekiq::Job

  def perform(event_json)
    event = Stripe::Event.construct_from(JSON.parse(event_json, symbolize_names: true))

    case event.type
    when 'invoice.payment_succeeded'
      handle_invoice_paid(event.data.object)
    when 'invoice.payment_failed'
      handle_invoice_failed(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_canceled(event.data.object)
    end
  end

  private

  def handle_invoice_paid(stripe_invoice)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_invoice.subscription)
    return unless subscription

    invoice = Invoice.find_or_initialize_by(stripe_invoice_id: stripe_invoice.id)
    invoice.update!(
      subscription: subscription,
      amount_cents: stripe_invoice.amount_due,
      status: :paid,
      paid_at: Time.current
    )
    subscription.update!(status: :active)
  end

  def handle_invoice_failed(stripe_invoice)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_invoice.subscription)
    return unless subscription

    subscription.update!(status: :past_due)
  end

  def handle_subscription_canceled(stripe_sub)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_sub.id)
    subscription&.update!(status: :canceled)
  end
end