Rails.application.routes.draw do
  mount Knock::Engine => '/knock'

  resources :spaces, only: [:show, :create, :update, :destroy]
  resources :spaces do
    resources :copies, only: [:create]
  end

  resources :users do
    resources :spaces, only: [:index]
    get :memberships, to: 'user_organization_memberships#user_memberships'
    post '/account/synchronization', to: 'accounts#synchronization'
    get '/account/new_subscription_iframe', to: 'accounts#new_subscription_iframe'
  end

  resources :organization, only: [:show]
  resources :organizations do
    resources :spaces, only: [:index]
    get :members, to: 'user_organization_memberships#organization_memberships'
  end
end
