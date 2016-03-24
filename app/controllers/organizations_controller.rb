class OrganizationsController < ApplicationController
  # TODO(matthew): Are there helpers for logged_in checking? Can we run a before_action here and elsewhere to strip the
  # current_user checks?
  def show
    @organization = Organization.find(params[:id])
    unless current_user && current_user.member_of?(@organization.id)
      head :unauthorized
      return
    end

    render json: OrganizationRepresenter.new(@organization).to_json
  end
end
