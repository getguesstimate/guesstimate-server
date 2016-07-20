class FactsController < ApplicationController
  before_action :authenticate, only: [:create, :update, :destroy]

  #GET /spaces
  #GET /spaces.json
  def index
    render json: FactsRepresenter.new(Fact.all).to_json
  end

  # POST /spaces
  # POST /spaces.json
  def create
    @fact = Fact.new(space_params)
    @fact.user = current_user

    if @fact.save
      render json: FactRepresenter.new(@fact).to_json
    else
      render json: @fact.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /spaces/1
  # PATCH/PUT /spaces/1.json
  def update
    if @fact.update(fact_params)
      @fact.take_checkpoint(current_user) if @space.needs_checkpoint?
      render json: FactRepresenter.new(@fact).to_json, status: :ok
    else
      render json: @fact.errors, status: :unprocessable_entity
    end
  end

  # DELETE /spaces/1
  # DELETE /spaces/1.json
  def destroy
    @fact.destroy
    head :no_content
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_fact
    @fact = Fact.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fact_params
    params.require(:fact).permit(:title, :value, :variable_name, :organization_id)
  end
end
