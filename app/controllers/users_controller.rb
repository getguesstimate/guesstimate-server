class UsersController < ApplicationController
  before_action :authenticate, except: [:index, :show, :create]

  def show
    @user = User.find(params[:id])
    render json: @user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def index
    if params[:auth0_id]
      @users = User.where(auth0_id: params[:auth0_id])
    else
      @users = User.all
    end
    render json: @users
  end

  def user_params
    params.require(:user).permit(:name, :picture, :auth0_id, :username)
  end
end

