class Account < ActiveRecord::Base
  belongs_to :user
  after_initialize :init

  def init
    self.has_payment_account = false
  end
end
