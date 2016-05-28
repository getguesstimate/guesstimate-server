class OrganizationsController < ApplicationController
  before_action :authenticate, only: [:create]

  def create
    @organization = Organization.new organiztion_params.merge(admin_id: current_user.id)
    if @organization.save
      render json: OrganizationRepresenter.new(@organization).to_json
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def show
    @organization = Organization.find(params[:id])
    render json: OrganizationRepresenter.new(@organization).to_json
  end

  private

  def organiztion_params
    params.require(:organization).permit(:name, :picture)
  end
end
