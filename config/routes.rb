Rails.application.routes.draw do
  get 'visit_logs/index'
  get 'visit_logs/new'
  get 'visit_logs/show'
  get 'visit_logs/edit'
  get 'daily_logs/new'
  get 'daily_logs/index'
  get 'daily_logs/show'
  get 'daily_logs/edit'
  get 'home/index'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  authenticated :user do
    root 'daily_logs#index', as: :authenticated_root
  end

  root "home#index"

  resources :daily_logs do
    get :analysis, on: :collection
  end

  resources :visit_logs
end
