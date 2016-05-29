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

  resources :organization, only: [:show, :create]
  resources :organizations do
    get :spaces, to: 'spaces#index'
    get :members, to: 'user_organization_memberships#organization_memberships'
    post :members, to: 'user_organization_memberships#invite_by_email'
  end

  resources :user_organization_memberships, only: [:destroy]
end
