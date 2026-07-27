Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:create, :show]
      resources :plans, only: [:index, :create, :show]
      resources :subscriptions, only: [:create, :show, :destroy]
      resources :invoices, only: [:index, :show]

      # Endpoint para recepção de eventos do Stripe Webhook
      post 'webhooks/stripe', to: 'webhooks#stripe'
    end
  end

  # Healthcheck
  get "up" => "rails/health#show", as: :rails_health_check
end
