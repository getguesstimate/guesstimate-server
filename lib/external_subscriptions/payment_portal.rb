module ExternalSubscriptions
  class PaymentPortal
    attr_accessor :href

    def initialize(entity_id, callback_url = 'http://www.getguesstimate.com')
      @href = Adapter.payment_portal_url(entity_id, callback_url)
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
