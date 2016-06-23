class CalculatorsController < ApplicationController
  before_action :authenticate, :set_space, :check_authorization, only: [:create]

  # GET /calculators/:id
  def show
    @calculator = Calculator.find(params[:id])
    render json: CalculatorRepresenter.new(@calculator).to_json
  end

  def create
    @calculator = @space.calculators.new calculator_params
    if (@calculator.save)
      render json: CalculatorRepresenter.new(@calculator).to_json
    else
      render json: @calculator.errors, status: :unprocessable_entity
    end
  end

  private
  def set_space
    @space = Space.find(params[:space_id])
  end

  def check_authorization
    head :unauthorized unless @space.editable_by_user? current_user
  end

  def calculator_params
    params.require(:calculator).permit(:title, :content, :share_image, input_ids: [], output_ids: [])
  end
end
