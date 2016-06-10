module ExternalSubscriptions
  class Adapter
    RESOURCE_NOT_FOUND_ERROR_CODE = 404

    class << self
      def new_subscription_iframe_url(entity_id, plan_id)
        params = {
          subscription: {
            plan_id: plan_id
          },
          customer: {
            id: entity_id
          },
          embed: true,
          iframe_messaging: true
        }
        return ChargeBee::HostedPage.checkout_new(params).hosted_page.url
      end

      def create_subscription(entity_id, plan_id)
        params = {
          plan_id: plan_id,
          customer: {
            id: entity_id
          }
        }
        ChargeBee::Subscription.create(params)
      end

      def payment_portal_url(entity_id, redirect_url)
        params = {
          redirect_url: redirect_url,
          customer: {
            id: entity_id
          }
        }

        return ChargeBee::PortalSession.create(params).portal_session.access_url
      end

      def has_account(entity_id)
        begin
          ChargeBee::Customer.retrieve(entity_id)
        rescue ChargeBee::InvalidRequestError => ex
          if exception_reveals_no_user(ex)
            return false
          else
            raise ex
          end
        end
        return true
      end

      def subscription(entity_id)
        subscriptions = ChargeBee::Subscription.subscriptions_for_customer(entity_id, :limit => 5).to_a
        return subscriptions[0].try(:subscription).try(:plan_id)
      end

      private
      def exception_reveals_no_user(ex)
        ex.try(:cause).try(:http_code) === RESOURCE_NOT_FOUND_ERROR_CODE
      end
    end
  end
end
