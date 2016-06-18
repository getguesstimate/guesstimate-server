class CopiesController < ApplicationController
  # GET /calculators/:id
  def show
    @calculator = Calculator.find(params[:space_id])
    render json: CalculatorRepresenter.new(calculator).to_json
  end
end
