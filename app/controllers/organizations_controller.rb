class OrganizationsController < ApplicationController
  # TODO(matthew): Are there helpers for logged_in checking? Can we run a before_action here and elsewhere to strip the
  # current_user checks?
  def show
    unless current_user && current_user.member_of?(params[:id])
      head :unauthorized
      return
    end

    @organization = Organization.find(params[:id])
    render json: OrganizationRepresenter.new(@organization).to_json
  end
end
