class UserMailer < ActionMailer::Base
  default from: "andrewmccalister@googlemail.com"

  def welcome_email(user)
  	@user = user
  	@url = "localhost:3000"
  	mail(:to => user.email, :subject => "Welcome to Bounce")
  end
end
