class InternalMailer < ApplicationMailer
  def organization_changed_member_count(organization, delta)
    @organization = organization
    @delta = delta
    mail to: ["matthew@getguesstimate.com", "ozzie@getguesstimate.com"], subject: "Organization #{delta} a member."
  end
end
