Rails.application.routes.draw do
  # Authentication routes
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Registration routes
  get  "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  # Family Dashboard
  get "dashboard", to: "family_accounts#show", as: :dashboard

  # Child Profiles (nested under family account)
  resources :family_accounts, only: [ :show ] do
    resources :child_profiles, except: [ :show ]
  end

  # Books and Drawings (nested under child profiles)
  resources :child_profiles, only: [] do
    resources :books do
      resources :drawings do
        member do
          patch :reorder
        end
      end
    end
  end

  # Profile Selection
  get  "select_profile", to: "profile_selections#index"
  post "select_profile/:id", to: "profile_selections#create", as: :create_profile_selection

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root path - profile selection or dashboard
  root "profile_selections#index"
end
