# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
InvoiceApp::Application.initialize!

#heroku sendgrid email setup
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :login,
  :user_name      => ENV['app12497979@heroku.com'],
  :password       => ENV['9apum8hn'],
  :domain         => 'heroku.com',
  :enable_starttls_auto => true
}

