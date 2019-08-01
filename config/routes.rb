Rails.application.routes.draw do
  get 'contents/new'
  get 'contents/index'
  resources :contents
  #get 'sessions/new'
  #get 'sessions/create'
  #get 'sessions/failure'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  get '/login', to: 'sessions#new', as: :login
  get '/content', to: 'content#index'
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/auth/failure', to: 'sessions#failure', via: [:get, :post]
  root to: 'contents#index'
end
