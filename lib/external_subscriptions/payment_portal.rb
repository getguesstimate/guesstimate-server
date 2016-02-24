module ExternalSubscriptions
  class PaymentPortal
    attr_accessor :href

    def initialize(user_id, callback_url = 'http://www.getguesstimate.com')
      @href = Adapter.payment_portal_url(user_id, callback_url)
    end

    def attributes
      return {
        href: @href,
      }
    end

    def to_json
      return attributes.to_json
    end
  end
end
