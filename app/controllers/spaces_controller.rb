class SpacesController < ApplicationController
  before_action :authenticate, only: [:create, :update, :destroy]
  before_action :set_space, only: [:show, :update, :destroy]
  before_action :check_authorization, only: [:update, :destroy]

  #GET /spaces
  #GET /spaces.json
  #TODO(matthew): params['strings'] or params[:symbols]?
  def index
    if params['user_id']
      @user = User.find(params['user_id'])
      if current_user && @user.id == current_user.id
        @spaces = @user.spaces
      else
        @spaces = @user.spaces.is_public
      end
    elsif params['organization_id']
      if current_user && current_user.member_of?(params['organization_id'])
        @spaces = Organization.find(params['organization_id']).spaces
      else
        head :unauthorized
        return
      end
    else
      # TODO(matthew): Do we have a use for this case? It carries some extra baggage that I'd like to remove, if we
      # don't really need it.
      @spaces = Space.visible_by(current_user).first(10)
    end
    #render json: @spaces.as_json(only: [:id, :name, :description, :updated_at, :user_id])
    render json: SpacesRepresenter.new(@spaces).to_json
  end

  # GET /spaces/1
  # GET /spaces/1.json
  def show
    if @space.is_private && !belongs_to_user
      head :unauthorized
    else
      newSpace = @space
      newSpace.graph = @space.cleaned_graph
      render json: SpaceRepresenter.new(newSpace).to_json
    end
  end

  # POST /spaces
  # POST /spaces.json
  def create
    @space = Space.new(space_params)
    @space.user = current_user

    if !space_params.has_key? :is_private
      @space.is_private = @space.user.prefers_private?
      if @space.organization
        @space.is_private = @space.is_private || organization.prefers_private?
      end
    end

    if @space.save
      render json: SpaceRepresenter.new(@space).to_json
    else
      render json: @space.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /spaces/1
  # PATCH/PUT /spaces/1.json
  def update
    if @space.update(space_params)
      render json: SpaceRepresenter.new(@space).to_json, status: :ok
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

  def belongs_to_user
    !current_user.nil? && (@space.user_id == current_user.id)
  end

  def check_authorization
    if !belongs_to_user
      head :unauthorized
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_space
    @space = Space.find(params[:id])
  end

  def graph_structure
    [
      metrics: [
        :id, :readableId, :name, location:[:row, :column]
      ],
      guesstimates: [
        :metric, :input, :guesstimateType, :description, data: []
      ]
    ]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def space_params
    params.require(:space).permit(:name, :description, :is_private, :organization_id, graph: graph_structure)
  end
end
