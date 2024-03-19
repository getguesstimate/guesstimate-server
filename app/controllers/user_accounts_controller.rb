class UserAccountsController < ApplicationController
  #GET /users/{id}/account/new_subscription_iframe
  def new_subscription_iframe
    user = User.find(params['user_id'])
    plan_id = params['plan_id']
    new_subscription_iframe = user.account.new_subscription_iframe(plan_id)
    render json: new_subscription_iframe.to_json
  end

  #POST /users/{id}/account/synchronization
  def synchronization
    user = User.find(params['user_id'])
    user.account.synchronize!
    render json: {}
  end
end
