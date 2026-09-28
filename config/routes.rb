Rails.application.routes.draw do
  get "welcome/index"

  devise_for :users

  authenticated :user do
    root to: "home#index", as: :user_root

    # Stocks
    resources :stocks do
      get :economy_history, on: :collection
      get :industry_history, on: :member

      # Other syntax option
      # collection do
      #   get :economy_history
      # end
      #
      # member do
      #   get :industry_history
      # end
    end
  end

  root "welcome#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
