Rails.application.routes.draw do
  get 'contents/new'
  get 'contents/index'
  resources :contents
  #get 'sessions/new'
  #get 'sessions/create'
  #get 'sessions/failure'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  get '/foo', to: 'contents#index'
  get '/login', to: 'sessions#new', as: :login
  get '/contents', to: 'contents#index'
  get 'users/new', to: 'sessions#new'
  #get '/auth/cas/callback', to: 'contents#index'
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/auth/failure', to: 'sessions#failure', via: [:get, :post]
  match '/auth/logout', to: 'sessions#logout', via: [:delete, :get]
  root to: 'contents#index'
end
