class CopiesController < ApplicationController
  before_action :authenticate, only: [:create]
  before_action :set_space, only: [:show]

  # POST /spaces/:id/copies
  # POST /spaces.json
  def create
    space_copy = Space.find(params[:space_id]).copy(current_user)

    if space_copy.save
      render json: SpaceRepresenter.new(space_copy).to_json
    else
      render json: space_copy.errors, status: :unprocessable_entity
    end
  end
end
