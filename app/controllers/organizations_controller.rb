class OrganizationsController < ApplicationController
  def show
    @organization = Organization.find(params[:id])
    render json: OrganizationRepresenter.new(@organization).to_json
  end
end
