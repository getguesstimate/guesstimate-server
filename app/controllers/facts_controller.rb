class FactsController < ApplicationController
  before_action :set_variables, :check_authorization

  #GET /organizations/:organization_id/facts
  #GET /organizations/:organization_id/facts.json
  def index
    render json: FactsRepresenter.new(@organization.facts).to_json
  end

  # POST /organizations/:organization_id/facts
  # POST /organizations/:organization_id/facts.json
  def create
    if @fact.save
      render json: FactRepresenter.new(@fact).to_json
    else
      render json: @fact.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/:organization_id/facts/:id
  # PATCH/PUT /organizations/:organization_id/facts/:id.json
  def update
    if @fact.update(fact_params)
      @fact.take_checkpoint(current_user, @organization.valid_api_token?(passed_api_token))
      render json: FactRepresenter.new(@fact).to_json, status: :ok
    else
      render json: @fact.errors, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/:organization_id/facts/:id
  # DELETE /organizations/:organization_id/facts/:id.json
  def destroy
    @fact.destroy
    head :no_content
  end

  private
  def passed_api_token
    request.headers['HTTP_API_TOKEN']
  end

  def check_authorization
    head :unauthorized unless @organization.present? && @organization.can_access?(current_user, passed_api_token)
  end

  def set_variables
    @organization = Organization.find(params[:organization_id])
    if params[:id].present?
      @fact = @organization.facts.find(params[:id])
    elsif params[:fact].present?
      @fact = @organization.facts.new(fact_params)
    end
  end

  def simulation_structure
    {sample: {values: []}, stats: [:length, :mean, :stdev, percentiles: ['5', '50', '95'], adjustedConfidenceInterval: []]}
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fact_params
    params.require(:fact).permit(
      :name,
      :metric_id,
      :exported_from_id,
      :category_id,
      :expression,
      :variable_name,
      simulation: simulation_structure
    )
  end
end
