class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAIL_FROM', 'no-reply@cinebook.test')
  layout 'mailer'
end
