Rails.application.routes.draw do

  mount Knock::Engine => '/knock'

  resources :calculators, only: [:show, :update, :destroy]

  resources :spaces, only: [:show, :create, :update, :destroy]
  resources :spaces do
    resources :calculators, only: [:create]
    resources :copies, only: [:create]

    member do
      patch '/enable_shareable_link', to: 'spaces#enable_shareable_link'
      patch '/disable_shareable_link', to: 'spaces#disable_shareable_link'
      patch '/rotate_shareable_link', to: 'spaces#rotate_shareable_link'
    end
  end

  resources :users do
    resources :spaces, only: [:index]
    get :memberships, to: 'user_organization_memberships#user_memberships'
    post '/account/synchronization', to: 'user_accounts#synchronization'
    patch '/finished_tutorial', to: 'users#finished_tutorial'
    get '/account/new_subscription_iframe', to: 'user_accounts#new_subscription_iframe'
  end

  resources :organization, only: [:show, :create]
  resources :organizations do
    resources :facts, only: [:index, :create, :update, :destroy]
    resources :fact_categories, only: [:create, :update, :destroy]
    get :spaces, to: 'spaces#index'
    get :members, to: 'user_organization_memberships#organization_memberships'
    get :invitees, to: 'user_organization_invitations#organization_invitations'
    post :members, to: 'user_organization_invitations#invite_by_email'

    member do
      patch '/enable_api_access', to: 'organizations#enable_api_access'
      patch '/disable_api_access', to: 'organizations#disable_api_access'
      patch '/rotate_api_token', to: 'organizations#rotate_api_token'
    end
  end

  resources :user_organization_memberships, only: [:destroy]
end
