class AccountsController < ApplicationController
  #GET /new_checkout_iframe
  def new_subscription_iframe
    user = User.find(params['user_id'])
    plan_id = params['plan_id']
    json_response = user.account.new_subscription_iframe(plan_id)
    render json: json_response.to_json
  end

  def synchronize
    user = User.find(params['user_id'])
    user.account.synchronize!
  end
end
