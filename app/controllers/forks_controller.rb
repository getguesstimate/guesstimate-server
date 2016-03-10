class ForksController < ApplicationController
  before_action :authenticate, only: [:create]
  before_action :set_space, only: [:show]

  # POST /spaces/:id/forks
  # POST /spaces.json
  def create
    space = Space.find(params[:space_id])
    space_fork = space.fork!(current_user)
    if space_fork.save
      render json: space_fork
    else
      render json: space_fork.errors, status: :unprocessable_entity
    end
  end
end
