Rails.application.routes.draw do
  get "welcome/index"

  devise_for :users

  authenticated :user do
    root to: "home#index", as: :user_root
  end

  root "welcome#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
