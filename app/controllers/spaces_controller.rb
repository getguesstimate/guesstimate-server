class SpacesController < ApplicationController
  before_action :set_space, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, except: [:index, :show]

  # GET /spaces
  # GET /spaces.json
  def index
    @spaces = Space.all
    render json: @spaces.as_json(only: [:id, :name, :description, :updated_at])
    #respond_to do |format|
      #puts format.inspect
        #format.html { render :index}
        #format.json { render json: @spaces }
      #end
  end

  # GET /spaces/1
  # GET /spaces/1.json
  def show
    render json: @space
  end

  # POST /spaces
  # POST /spaces.json
  def create
    @space = Space.new(space_params)
    @space.user = current_user
    if @space.save
      render json: @space
    else
      render json: @space.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /spaces/1
  # PATCH/PUT /spaces/1.json
  def update
    if @space.update(space_params)
      render json: @space, status: :ok
    else
      render json: @space.errors, status: :unprocessable_entity
    end
  end

  # DELETE /spaces/1
  # DELETE /spaces/1.json
  def destroy
    @space.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_space
      @space = Space.find(params[:id])
    end

    def graph_structure
      [
        metrics: [
          :id, :space, :readableId, :name, location:[:row, :column]
        ],
        guesstimates: [
          :metric, :input, :guesstimateType, :description
        ]
      ]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def space_params
      params.require(:space).permit(:name, :description, :user_id, graph: graph_structure)
    end
end
