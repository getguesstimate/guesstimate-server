module ExternalSubscriptions
  class NewSubscriptionIframe
    attr_accessor :hosted_page, :website_name

    def initialize(user_id, plan_id)
      @hosted_page = Adapter.new_subscription_hosted_page(user_id, plan_id)
    end

    def attributes
      return {
        # Full Chargebee hosted page object, passed to Chargebee.js v2
        # openCheckout's `hostedPage` callback for in-context checkout.
        hosted_page: @hosted_page,
        # Kept for backwards compatibility with older clients.
        href: @hosted_page && @hosted_page[:url],
        website_name: Rails.application.secrets[:chargebee_site]
      }
    end

    def to_json
      return attributes.to_json
    end
  end
end
