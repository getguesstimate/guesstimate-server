module ExternalSubscriptions
  class NewSubscriptionIframe
    attr_accessor :href, :website_name

    def initialize(user_id, plan_id, website_name = 'guesstimate-test')
      @href = Adapter.new_subscription_iframe_url(user_id, plan_id)
      @website_name = website_name
    end

    def attributes
      return {
        href: @href,
        website_name: @website_name
      }
    end

    def to_json
      return attributes.to_json
    end
  end
end
