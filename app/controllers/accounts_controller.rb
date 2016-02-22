class AccountsController < ApplicationController
  #GET /new_checkout_iframe
  def new_subscription_iframe
    user = User.find(params['user_id'])
    plan_id = params['plan_id']
    new_subscription_iframe = user.account.new_subscription_iframe(plan_id)
    render json: new_subscription_iframe.to_json
  end

  def synchronize
    user = User.find(params['user_id'])
    user.account.synchronize!
  end
end
