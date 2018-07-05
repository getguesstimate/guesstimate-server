class AdminController < ApplicationController
  def bad_show
    raise "Test error"
  end
end
