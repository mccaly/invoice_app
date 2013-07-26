class ApprovalMailer < ActionMailer::Base
	 default from: "support@get-bounce.com"

	def invoice_email_approval(user)
		@user = user
  		#@url = http://localhost:3000/users/@user.id/approve
  		mail(:to => user.email, :subject => "Invoices need approval to be sent")
	end

	def reminder_email_approval(user)
		@user = user
		mail(:to => user.email, :subject => "Invoices overdue. Send reminder emails now")
	end

end