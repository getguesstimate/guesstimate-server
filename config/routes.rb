Rails.application.routes.draw do
  mount Knock::Engine => '/knock'

  resources :spaces, only: [:show, :create, :update, :destroy]
  resources :spaces do
    resources :copies, only: [:create]
  end

  resources :users do
    resources :spaces, only: [:index]
    post '/account/synchronization', to: 'accounts#synchronization'
    get '/account/new_subscription_iframe', to: 'accounts#new_subscription_iframe'
  end

  resources :organization, only: [:show]
  resources :organizations do
    resources :spaces, only: [:index]
    resources :members, controller: 'users', only: [:index]
  end
end
