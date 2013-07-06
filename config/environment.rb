# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
InvoiceApp::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => ENV['app12497979@heroku.com'],
  :password       => ENV['9apum8hn'],
  :domain         => 'heroku.com',
  :enable_starttls_auto => true
}

