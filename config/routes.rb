# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :journal_entries, only: [:index] do
        collection do
          get ":year/:month", to: "journal_entries#show", as: :show
        end
      end
    end
  end

  mount_devise_token_auth_for "User", at: "auth"
end
