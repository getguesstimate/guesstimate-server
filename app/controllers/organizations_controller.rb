class OrganizationsController < ApplicationController
  before_action :authenticate, only: [:create]

  def create
    @organization = Organization.new organization_params.merge(admin_id: current_user.id)
    if @organization.save
      render json: OrganizationRepresenter.new(@organization).to_json(
        user_options: {
          current_user_is_member: true,
          current_user_is_admin: true,
        }
      )
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def show
    @organization = Organization.find(params[:id])
    render json: OrganizationRepresenter.new(@organization).to_json(
      user_options: {
        current_user_is_member: current_user.present? && current_user.member_of?(@organization.id),
        current_user_is_admin: current_user.present? && @organization.admin_id == current_user.id,
      }
    )
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :picture)
  end
end
