require 'roar/decorator'

class AccountRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :has_payment_account

  link :payment_portal do
    represented.payment_portal.try(:href) || ''
  end
end
