class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :enable_api_access, :disable_api_access, :rotate_api_token]
  before_action :authenticate, only: [:create, :enable_api_access, :disable_api_access, :rotate_api_token]
  before_action :ensure_admin, only: [:enable_api_access, :disable_api_access, :rotate_api_token]

  def create
    @organization = Organization.new organization_params.merge(admin_id: current_user.id)
    if @organization.save
      # TODO(matthew): Check that we don't need to hard code current_user_is_... params in this case.
      render_organization
    else
      render_errors
    end
  end

  def show
    render_organization
  end

  def enable_api_access
    if @organization.enable_api_access!
      render_organization
    else
      render_errors
    end
  end

  def disable_api_access
    if @organization.disable_api_access!
      render_organization
    else
      render_errors
    end
  end

  def rotate_api_token
    if @organization.rotate_api_token!
      render_organization
    else
      render_errors
    end
  end

  private

  def current_user_is_admin?
    current_user.present? && @organization.present? && @organization.admin_id == current_user.id
  end

  def render_organization
    render json: OrganizationRepresenter.new(@organization).to_json(
      user_options: {
        current_user_is_member: current_user.present? && current_user.member_of?(@organization.id),
        current_user_is_admin: current_user_is_admin?,
      }
    )
  end

  def render_errors
    render json: @organization.errors, status: :unprocessable_entity
  end

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def ensure_admin
    head :unauthorized unless current_user_is_admin?
  end

  def organization_params
    params.require(:organization).permit(:name, :picture, :plan)
  end
end
