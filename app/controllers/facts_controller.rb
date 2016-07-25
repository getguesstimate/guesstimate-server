class FactsController < ApplicationController
  before_action :authenticate, :set_variables, :check_authorization

  #GET /organizations/:organization_id/facts
  #GET /organizations/:organization_id/facts.json
  def index
    render json: FactsRepresenter.new(@organization.facts).to_json
  end

  # POST /facts
  # POST /facts.json
  def create
    if @fact.save
      render json: FactRepresenter.new(@fact).to_json
    else
      render json: @fact.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /facts/1
  # PATCH/PUT /facts/1.json
  def update
    if @fact.update(fact_params)
      render json: FactRepresenter.new(@fact).to_json, status: :ok
    else
      render json: @fact.errors, status: :unprocessable_entity
    end
  end

  # DELETE /facts/1
  # DELETE /facts/1.json
  def destroy
    @fact.destroy
    head :no_content
  end

  private
  def check_authorization
    head :unauthorized unless @organization.present? && current_user.member_of?(@organization.id)
  end

  def set_variables
    if params[:id].present?
      @fact = Fact.find(params[:id])
      @organization = @fact.organization
    elsif params[:organization_id].present?
      @organization = Organization.find(params[:organization_id])
    elsif params[:fact].present?
      @fact = Fact.new(fact_params)
      @organization = Organization.find(params[:fact][:organization_id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fact_params
    params.require(:fact).permit(:name, :expression, :variable_name, :organization_id)
  end
end
