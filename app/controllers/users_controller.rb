class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    render json: user_representation(@user)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      Analytics.identify(
        user_id: @user.id,
        traits: {
          name: @user.name,
          email: @user.email,
          domain_name: @user.domain_name,
          gender: @user.gender,
          locale: @user.locale,
          location: @user.location,
          created_at: @user.created_at
        }
      )
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
        Authentor.new().run
        @users = User.where(auth0_id: params[:auth0_id])
      end
    else
      @users = User.last(10)
    end

    render json: UsersRepresenter.new(@users).to_json
  end

  private
  def user_params
    params.require(:user).permit(:name, :picture, :auth0_id, :job_title, :email, :username, :location, :locale, :gender)
  end

  def user_representation(user)
    UserRepresenter.new(user).to_json(user_options: {is_current_user: is_current_user?(user)})
  end

  def is_current_user?(user)
    current_user.present? && (current_user.id == user.id)
  end
end
