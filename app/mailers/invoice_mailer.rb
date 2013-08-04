class InvoiceMailer < ActionMailer::Base
  default from: "support@get-bounce.com"

  def invoice_to_client(invoice)
  	@account = invoice.account
  	@invoice = invoice
  	@user = invoice.user
  	mail(:to => @account.contact_email, :subject => "You have received an invoice") do |format|
      format.text
      format.pdf do
        attachments['invoice.pdf'] = WickedPDF.new.pdf_from_string(render_to_string(:pdf => 'invoice', :template => 'invoices/client_invoice_view/@invoice.id.pdf'))
      end
    end
  end

  def reminder_to_client(invoice)
  	@account = invoice.account
  	@invoice = invoice
  	@user = invoice.user
  	mail(:to => @account.contact_email, :subject => "Invoice payment due tomorrow")
  end

end
