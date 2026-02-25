Rails.application.routes.draw do
  # Landing page
  root "pages#home"

  # Authentication routes
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Registration routes
  get  "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  # Magic link authentication (for users with incomplete onboarding)
  nopassword EmailAuthenticationsController

  # Onboarding routes
  post  "onboarding/start", to: "onboarding#start", as: :onboarding_start
  get   "onboarding/name", to: "onboarding#name"
  patch "onboarding/name", to: "onboarding#update_name"
  get   "onboarding/child", to: "onboarding#child_profile", as: :onboarding_child_profile
  post  "onboarding/child", to: "onboarding#create_child", as: :onboarding_child
  post  "onboarding/complete", to: "onboarding#complete", as: :complete_onboarding

  # Email verification
  get "verify_email/:token", to: "email_verifications#show", as: :verify_email

  # Family Dashboard
  get "dashboard", to: "family_accounts#show", as: :dashboard

  # Child Profiles (nested under family account)
  resources :family_accounts, only: [ :show ] do
    resources :child_profiles, except: [ :show ]
  end

  # Books and Drawings (nested under child profiles)
  resources :child_profiles, only: [] do
    resources :books do
      resources :drawings
    end
  end

  # Family Library (books across all child profiles)
  get "library", to: "library#index", as: :library

  # Book Editor (nested under child profiles and books)
  namespace :editor do
    resources :child_profiles, only: [] do
      resources :books, only: [ :edit, :update ] do
        resources :pages, only: [ :create, :update, :destroy ]
      end
    end
  end

  # AI Story Generation (nested under child profiles and books)
  namespace :ai do
    resources :child_profiles, only: [] do
      resources :books, only: [] do
        resources :story_generations, only: [ :new, :create, :show ] do
          resources :page_generations, only: [ :show, :update ]
        end
      end
    end
  end

  # Profile Selection
  get  "select_profile", to: "profile_selections#index"
  post "select_profile/:id", to: "profile_selections#create", as: :create_profile_selection

  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"

    resources :users, only: [ :index, :show, :update ]
    resources :families, only: [ :index, :show ]
    resources :content, only: [ :index, :show ]
    resources :ai_usage, only: [ :index ]
    resources :audit_logs, only: [ :index, :show ]
    resources :settings, only: [ :index, :update ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
