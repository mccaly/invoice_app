class UserMailer < ActionMailer::Base
  default from: "support@get-bounce.com"

  def welcome_email(user)
  	@user = user
  	@url = "localhost:3000"
  	mail(:to => user.email, :subject => "Welcome to Bounce")
  end

  def trial_period_reminder_5days(user)
  	@user = user
  	@url = "localhost:3000"
  	mail(:to => user.email, :subject => "Bounce 30 day free trial expiring")
  end

  def new_user(user)
    @user = user
    @url = "localhost:3000"
    mail(:to => "andrewmccalister@googlemail.com", :subject => "new user has signed up")
  end

end
