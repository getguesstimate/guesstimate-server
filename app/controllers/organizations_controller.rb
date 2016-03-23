class OrganizationsController < ApplicationController
  def show
    unless current_user
      head :unauthorized
      return
    end

    @organization = Organization.find(params[:id])
    if @organization.members.exists? current_user
      render json: OrganizationRepresenter.new(@organization).to_json
    else
      head :unauthorized
    end
  end
end
