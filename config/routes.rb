Rails.application.routes.draw do
  mount Knock::Engine => '/knock'

  resources :spaces, only: [:show, :create, :update, :destroy], format: :json
  resources :spaces do
    resources :copies, only: [:create], format: :json
  end

  resources :users do
    resources :spaces, only: [:index], format: :json
    get :memberships, to: 'user_organization_memberships#user_memberships', format: :json
    post '/account/synchronization', to: 'accounts#synchronization', format: :json
    get '/account/new_subscription_iframe', to: 'accounts#new_subscription_iframe', format: :json
  end

  resources :organization, only: [:show], format: :json
  resources :organizations do
    resources :spaces, only: [:index], format: :json
    get :members, to: 'user_organization_memberships#organization_memberships', format: :json
  end
end
