class FactCategoriesController < ApplicationController
  before_action :authenticate, :set_variables, :check_authorization

  # TODO(Ozzie): Should the api be .../fact_categories or .../categories ?
  # POST /organizations/:organization_id/fact_categories
  # POST /organizations/:organization_id/fact_categories.json
  def create
    if @fact_category.save
      render json: FactCategoryRepresenter.new(@fact_category).to_json
    else
      render json: @fact_category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/:organization_id/fact_categories/:id
  # PATCH/PUT /organizations/:organization_id/fact_categories/:id.json
  def update
    if @fact_category.update(fact_category_params)
      render json: FactCategoryRepresenter.new(@fact_category).to_json, status: :ok
    else
      render json: @fact_category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/:organization_id/fact_categories/:id
  # DELETE /organizations/:organization_id/fact_categories/:id.json
  def destroy
    @fact_category.destroy
    head :no_content
  end

  private

  def set_variables
    @organization = Organization.find(params[:organization_id])
    if params[:id].present?
      @fact_category = @organization.fact_categories.find(params[:id])
    elsif params[:fact_category].present?
      @fact_category = @organization.fact_categories.new(fact_category_params)
    end
  end

  def check_authorization
    head :unauthorized unless @organization.present? && current_user.member_of?(@organization.id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fact_category_params
    params.require(:fact_category).permit(:name)
  end
end
