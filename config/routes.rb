Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  #
  post "send_verification_code", to: "auth#send_verification_code"
  post "verify_code_and_register", to: "auth#verify_code_and_register"
  post "login", to: "auth#login"


  namespace :api do
    resources :ads, only: [ :create, :index, :show ]
  end

  namespace :api do
    get "all_ads", to: "all_ads#index"
  end

  namespace :api do
    resources :ad_requests, path: "requests", only: [ :create, :index ] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  # publisher registration routes
  namespace :api do
    post "publisher/connect-ga", to: "publishers#connect_ga"
    post "publisher/complete-registration", to: "publishers#complete_registration"
    get "publisher/analytics-snapshot", to: "publishers#analytics_snapshot"
  end

  # namespace :api do
  #   get 'publishers/:publisher_id'
  # end
end
