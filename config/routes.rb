require 'sidekiq/web'

Rails.application.routes.draw do
  # Swagger UI Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Sidekiq Web Dashboard (em dev)
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  namespace :api do
    namespace :v1 do
      resources :customers, only: [:create, :show]
      resources :plans, only: [:index, :create, :show]
      resources :subscriptions, only: [:create, :show, :destroy]
      resources :invoices, only: [:index, :show]

      post 'webhooks/stripe', to: 'webhooks#stripe'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end