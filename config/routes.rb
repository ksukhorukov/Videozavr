require 'sidekiq/web'

Rails.application.routes.draw do
  
  root to: 'static_pages#home'

  resources :users
  resources :videos
  resources :sessions, only: [:new, :create, :destroy]

  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

  mount Sidekiq::Web => '/sidekiq'

end


