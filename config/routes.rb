Rails.application.routes.draw do
  mount Knock::Engine => '/knock'

  resources :calculators, only: [:show]

  resources :spaces, only: [:show, :create, :update, :destroy]
  resources :spaces do
    resources :calculators, only: [:create]
    resources :copies, only: [:create]
  end

  resources :users do
    resources :spaces, only: [:index]
    get :memberships, to: 'user_organization_memberships#user_memberships'
    post '/account/synchronization', to: 'user_accounts#synchronization'
    get '/account/new_subscription_iframe', to: 'user_accounts#new_subscription_iframe'
  end

  resources :organization, only: [:show, :create]
  resources :organizations do
    resources :facts, only: [:index, :create, :update, :destroy]
    get :spaces, to: 'spaces#index'
    get :members, to: 'user_organization_memberships#organization_memberships'
    get :invitees, to: 'user_organization_invitations#organization_invitations'
    post :members, to: 'user_organization_invitations#invite_by_email'
  end

  resources :user_organization_memberships, only: [:destroy]
end
