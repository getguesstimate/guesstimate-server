class InternalMailer < ApplicationMailer
  def organization_changed_member_count(organization)
    @organization = organization
    mail to: ["matthew@getguesstimate.com", "ozzie@getguesstimate.com"], subject: "Organization added or removed member."
  end
end
