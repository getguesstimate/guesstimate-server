class FactsController < ApplicationController
  before_action :authenticate, :set_variables, :check_authorization

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

  # PATCH/PUT /organizations/:organization_id/facts/1
  # PATCH/PUT /organizations/:organization_id/facts/1.json
  def update
    if @fact.update(fact_params)
      render json: FactRepresenter.new(@fact).to_json, status: :ok
    else
      render json: @fact.errors, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/:organization_id/facts/1
  # DELETE /organizations/:organization_id/facts/1.json
  def destroy
    @fact.destroy
    head :no_content
  end

  private
  def check_authorization
    head :unauthorized unless @organization.present? && current_user.member_of?(@organization.id)
  end

  def set_variables
    @organization = Organization.find(params[:organization_id])
    if params[:id].present?
      @fact = @organization.facts.find(params[:id])
    elsif params[:fact].present?
      @fact = @organization.facts.new(fact_params)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fact_params
    params.require(:fact).permit(:name, :expression, :variable_name, values: [])
  end
end
