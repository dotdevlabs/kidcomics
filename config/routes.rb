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

  # Onboarding routes
  post  "onboarding/start", to: "onboarding#start", as: :onboarding_start
  get   "onboarding/name", to: "onboarding#name"
  patch "onboarding/name", to: "onboarding#update_name"
  get   "onboarding/child", to: "onboarding#child_profile"
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
      member do
        patch :toggle_favorite
      end

      resources :drawings do
        member do
          patch :reorder
        end
      end
    end
  end

  # Family Library (books across all child profiles)
  get "library", to: "library#index", as: :library

  # AI Story Generation (nested under child profiles and books)
  namespace :ai do
    resources :child_profiles, only: [] do
      resources :books, only: [] do
        resources :story_generations, only: [ :new, :create, :show ] do
          member do
            post :retry
          end

          resources :page_generations, only: [ :show, :update ] do
            member do
              post :regenerate
            end
          end
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

    resources :users, only: [ :index, :show, :update ] do
      member do
        patch :suspend
        patch :restore
      end
    end

    resources :families, only: [ :index, :show ]

    resources :content, only: [ :index, :show ] do
      member do
        patch :approve
        patch :flag
        patch :reject
      end
    end

    resources :ai_usage, only: [ :index ]
    resources :audit_logs, only: [ :index, :show ]

    resources :settings, only: [ :index, :update ] do
      collection do
        post :test_email
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
