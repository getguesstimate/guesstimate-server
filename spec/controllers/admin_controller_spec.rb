require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  describe "#bad_show" do
    it "raises an exception" do
      expect {
        get :bad_show
      }.to raise_error("Test error")
    end
  end
end
