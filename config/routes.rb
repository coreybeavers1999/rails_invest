Rails.application.routes.draw do
  get "welcome/index"

  devise_for :users

  authenticated :user do
    root to: "home#index", as: :user_root

    # Stocks
    resources :stocks do
      collection do
        get :economy_history
      end

      member do

      end
    end
  end

  root "welcome#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
