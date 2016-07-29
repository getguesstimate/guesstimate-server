class SpacesController < ApplicationController
  before_action :authenticate, only: [:create, :update, :destroy]
  before_action :set_space, only: [:show, :update, :destroy]
  before_action :check_authorization, only: [:update, :destroy]
  before_action :check_previous_author, only: [:update]

  #caches_action :show

  #GET /spaces
  #GET /spaces.json
  #TODO(matthew): params['strings'] or params[:symbols]?
  def index
    if params['user_id']
      @user = User.find(params['user_id'])
      if current_user && @user.id == current_user.id
        organization_ids = @user.organizations.map {|o| o.id}
        @spaces = @user.spaces.where(organization_id: [nil] + organization_ids)
      else
        @spaces = @user.spaces.is_public
      end
    elsif params['organization_id']
      if current_user && current_user.member_of?(params['organization_id'])
        @spaces = Organization.find(params['organization_id']).spaces
      else
        @spaces = Organization.find(params['organization_id']).spaces.is_public
      end
    end
    render json: SpacesRepresenter.new(@spaces).to_json
  end

  # GET /spaces/1
  # GET /spaces/1.json
  def show
    can_edit = current_user && @space.editable_by_user?(current_user)
    if @space.is_public? || can_edit
      newSpace = @space
      newSpace.graph = @space.cleaned_graph
      render json: SpaceRepresenter.new(newSpace).to_json(user_options: {current_user_can_edit: can_edit})
    else
      head :unauthorized
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
        @space.is_private = @space.is_private || @space.organization.prefers_private?
      end
    end

    if @space.save
      render json: SpaceRepresenter.new(@space).to_json(user_options: {current_user_can_edit: true})
    else
      render json: @space.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /spaces/1
  # PATCH/PUT /spaces/1.json
  def update
    filtered_params = space_params.reject { |k,v| k == 'previous_updated_at' }
    if @space.update(filtered_params)
      @space.take_checkpoint(current_user) if @space.needs_checkpoint?
      render json: SpaceRepresenter.new(@space).to_json(user_options: {current_user_can_edit: true}), status: :ok
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

  def check_authorization
    head :unauthorized unless @space.editable_by_user? current_user
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_space
    @space = Space.find(params[:id])
  end

  def check_previous_author
    if space_params[:previous_updated_at].present? && @space.someone_else_editing?(current_user, space_params[:previous_updated_at])
      render json: SpaceRepresenter.new(@space).to_json(user_options: {current_user_can_edit: true}), status: :conflict
    end
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
    # TODO(matthew): Clean up client so we don't need to nest previous_updated_at within space.
    params.require(:space).permit(:name, :description, :is_private, :previous_updated_at, :organization_id, graph: graph_structure)
  end
end
