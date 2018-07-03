class CopiesController < ApplicationController
  before_action :authenticate_user, only: [:create]

  # POST /spaces/:id/copies
  # POST /spaces.json
  def create
    space = Space.find(params[:space_id])
    unless current_user && space.visible_to?(current_user)
      head :unauthorized
      return
    end

    space_copy = space.copy(current_user)

    if space_copy.save
      render json: SpaceRepresenter.new(space_copy).to_json(user_options: {current_user_can_edit: true})
    else
      render json: space_copy.errors, status: :unprocessable_entity
    end
  end
end
