class CalculatorsController < ApplicationController
  # GET /calculators/:id
  def show
    @calculator = Calculator.find(params[:id])
    render json: CalculatorRepresenter.new(@calculator).to_json
  end
end
