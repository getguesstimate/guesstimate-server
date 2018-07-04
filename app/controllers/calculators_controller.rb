class CalculatorsController < ApplicationController
  before_action :set_variables
  before_action :authenticate_user, :check_edit_authorization, except: [:show]
  before_action :check_show_authorization, only: [:show]

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

  def update
    if (@calculator.update calculator_params)
      render json: CalculatorRepresenter.new(@calculator).to_json
    else
      render json: @calculator.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @calculator.destroy
    head :no_content
  end

  private
  def set_variables
    if (params[:id].present?)
      @calculator = Calculator.find(params[:id])
      @space = @calculator.space
    elsif (params[:space_id].present?)
      @space = Space.find(params[:space_id])
    end
  end

  def check_show_authorization
    head :unauthorized unless @calculator.space.viewable_by_user? current_user
  end

  def check_edit_authorization
    head :unauthorized unless @space.editable_by_user? current_user
  end

  def calculator_params
    params.require(:calculator).permit(:title, :content, :share_image, input_ids: [], output_ids: [])
  end
end
