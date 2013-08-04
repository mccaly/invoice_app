class InvoiceMailer < ActionMailer::Base
  default from: "support@get-bounce.com"

  def invoice_to_client(invoice)
  	@account = invoice.account
  	@invoice = invoice
  	@user = invoice.user
  	mail(:to => @account.contact_email, :subject => "You have received an invoice")
  end

  def reminder_to_client(invoice)
  	@account = invoice.account
  	@invoice = invoice
  	@user = invoice.user
  	mail(:to => @account.contact_email, :subject => "Invoice payment due tomorrow")
  end

end
