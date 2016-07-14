class CalculatorsController < ApplicationController
  before_action :authenticate, :set_space, :check_create_authorization, only: [:create]
  before_action :set_calculator, :check_show_authorization, only: [:show]

  # GET /calculators/:id
  def show
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

  def set_calculator
    @calculator = Calculator.find(params[:id])
  end

  def check_show_authorization
    head :unauthorized unless @calculator.space.viewable_by_user? current_user
  end

  def check_create_authorization
    head :unauthorized unless @space.editable_by_user? current_user
  end

  def calculator_params
    params.require(:calculator).permit(:title, :content, :share_image, input_ids: [], output_ids: [])
  end
end
