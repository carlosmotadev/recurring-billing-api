module Api
  module V1
    class WebhooksController < ActionController::API
      def stripe
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

        event = nil

        begin
          if endpoint_secret.present?
            event = ::Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
          else
            data = JSON.parse(payload, symbolize_names: true)
            event = ::Stripe::Event.construct_from(data)
          end
        rescue JSON::ParserError, ::Stripe::SignatureVerificationError => e
          return render json: { error: e.message }, status: :bad_request
        end

        # Delega o evento para processamento em segundo plano (Sidekiq)
        StripeWebhookJob.perform_async(event.to_json)

        render json: { message: 'Webhook received successfully' }, status: :ok
      end
    end
  end
end