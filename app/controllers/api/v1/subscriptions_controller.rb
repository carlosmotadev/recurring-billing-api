module Api
  module V1
    class SubscriptionsController < BaseController
      def create
        customer = Customer.find(subscription_params[:customer_id])
        plan = Plan.find(subscription_params[:plan_id])

        result = Stripe::CreateSubscriptionService.new(
          customer: customer,
          plan: plan,
          payment_method_id: subscription_params[:payment_method_id]
        ).call

        if result.success?
          render json: result.subscription, status: :created
        else
          render json: { error: result.errors }, status: :unprocessable_entity
        end
      end

      def show
        subscription = Subscription.find(params[:id])
        render json: subscription, include: [:customer, :plan, :invoices]
      end

      private

      def subscription_params
        params.require(:subscription).permit(:customer_id, :plan_id, :payment_method_id)
      end
    end
  end
end