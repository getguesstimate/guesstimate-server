class UsersController < ApplicationController
  before_action :set_variables, only: [:show, :finished_tutorial]
  before_action :authenticate, :verify_is_current_user, only: [:finished_tutorial]

  def show
    render json: user_representation(@user)
  end

  def finished_tutorial
    @user.update_attributes needs_tutorial: false
    render json: user_representation(@user)
  end

  def create
    existing_user = User.find_by_auth0_id(user_params[:auth0_id])
    if existing_user.present?
      render json: user_representation(existing_user)
      return
    end

    @user = User.new(user_params)
    if @user.save
      @user.identify
      render json: user_representation(@user)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def index
    if params[:auth0_id]
      @users = User.where(auth0_id: params[:auth0_id])

      if @users.empty?
        Rails.logger.error "Requested user not found.  Syncing with authentication provider."
        Authentor.new().fetch_users
        @users = User.where(auth0_id: params[:auth0_id])
      end
    else
      @users = User.last(10)
    end

    render json: UsersRepresenter.new(@users).to_json
  end

  private
  def user_params
    params.require(:user).permit(:name, :picture, :auth0_id, :company, :email, :username, :location, :locale, :gender)
  end

  def user_representation(user)
    UserRepresenter.new(user).to_json(user_options: {is_current_user: is_current_user?(user)})
  end

  def is_current_user?(user)
    current_user.present? && (current_user.id == user.id)
  end

  def set_variables
    @user = params[:id].present? ? User.find(params[:id]) : User.find(params[:user_id])
  end

  def verify_is_current_user
    head :unauthorized unless is_current_user? @user
  end
end
