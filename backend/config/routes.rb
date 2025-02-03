require 'sidekiq/web'

Rails.application.routes.draw do
  # Active Storage engine (not auto-mounted in api_only mode)
  mount ActiveStorage::Engine => '/rails/active_storage'

  mount ActionCable.server => '/cable'

  get '/health', to: 'health#liveness'
  get '/ready',  to: 'health#readiness'

  mount Sidekiq::Web => '/sidekiq' # protect in production via Nginx basic-auth or a Rack constraint

  namespace :api do
    namespace :v1 do
      scope path: 'auth', as: 'auth' do
        post   'signup',  to: 'sessions#signup'
        post   'login',   to: 'sessions#login'
        post   'refresh', to: 'sessions#refresh'
        delete 'logout',  to: 'sessions#logout'
        get    'me',      to: 'sessions#me'
      end

      resources :movies, only: %i[index show] do
        collection { get :featured }
      end

      resources :theaters, only: %i[index show] do
        resources :shows, only: %i[index], controller: 'theater_shows'
      end

      resources :shows, only: %i[show] do
        member do
          get  :seats
          post :lock_seats
        end
      end

      resources :bookings, only: %i[index show create] do
        member do
          post :cancel
          post :confirm
        end
      end

      namespace :webhooks do
        post 'stripe',  to: 'stripe#receive'
        post 'phonepe', to: 'phonepe#receive'
      end

      namespace :admin do
        resources :movies
        resources :theaters do
          resources :screens, shallow: true do
            resources :seats, only: %i[index create destroy]
          end
        end
        resources :shows
        resources :featured_movies, only: %i[index create destroy]
        resources :bookings, only: %i[index show]
        resources :users,    only: %i[index update destroy]
        get 'analytics/overview', to: 'analytics#overview'
        get 'analytics/revenue',  to: 'analytics#revenue'
        get 'analytics/occupancy', to: 'analytics#occupancy'
      end
    end
  end

  match '*unmatched', to: 'application#route_not_found', via: :all
end
