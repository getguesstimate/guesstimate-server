class ApplicationMailer < ActionMailer::Base
  default from: "guesstimate-no-reply@getguesstimate.com"
  layout 'mailer'
end
