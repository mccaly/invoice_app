class InvoicesController < ApplicationController

	def new

	end

	def create
	end

	def edit
		@invoice = Invoice.find(params[:id])
		@invoice_units = @invoice.unit_tallys
		@invoice_total = @invoice.amount
		@invoice_basecost = @invoice.basecost_tallys
	end

	def update
		@deal = Deal.find(params[:deal_id])
		@invoice = Invoice.find(params[:id])
		@invoice.update_attributes(params[:invoice])
		@invoice.save
			if @invoice.adjust_total == 'true'
				@invoice.amount = @invoice.adjust_total_amount
				@invoice.save
				flash[:success] = "Invoice updated"
				redirect_to deal_invoice_path(@deal, @invoice)
			else
				@invoice.amount = (@invoice.basecost_total + @invoice.metered_total)
				@invoice.save
				flash[:success] = "Invoice updated"
				redirect_to deal_invoice_path(@deal, @invoice)
			end
	end

	def invoice
		@invoice = Invoice.new
	end

	def show
		@account = Account.find_by(params[:account_id])
		@invoice = Invoice.find(params[:id])
		@user = @invoice.user
		@deal = Deal.find(params[:deal_id])
		@invoice_units = @invoice.unit_tallys
		@invoice_total = @invoice.amount
		@invoice_basecost = @invoice.basecost_tallys
		#@units_tally = @invoice_units.tallys
	end

	def update_and_email_invoice
    	@invoice = Invoice.find(params[:id])
    	@invoice.update_attributes(email_invoice_approved: true)
  	end

  	def email_invoice
  		@invoice = Invoice.find(params[:id])
  		@invoice.update_attributes(email_invoice_approved: true)
  		@invoice.save
  		InvoiceMailer.invoice_to_client(@invoice).deliver
  		redirect_to approve_user_path(@invoice.user)
  	end

  	def email_reminder
  		@invoice = Invoice.find(params[:id])
  		@invoice.update_attributes(email_reminder_approved: true)
  		@invoice.save
  		InvoiceMailer.reminder_to_client(@invoice).deliver
  		redirect_to approve_user_path(@invoice.user)
  	end


  	def client_invoice_view
  		@invoice = Invoice.find(params[:id])
  		@user = @invoice.user
  		@unit = @invoice.units
		@deal = @invoice.deal
		@invoice_units = @invoice.unit_tallys
		@invoice_total = @invoice.amount
		@invoice_basecost = @invoice.basecost_tallys
  	end
end
