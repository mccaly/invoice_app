class InvoicesController < ApplicationController

	def new

	end

	def create
		
	end

	def update
		@deal = Deal.find(params[:deal_id])
		@invoice = Invoice.find(params[:id])
		@invoice.update_attributes(params)
		#@invoice.update_attributes(params[:invoice])
		#@invoice.status = params[:status]
		if @invoice.update_attributes
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
		@unit = @invoice.units
		@deal = Deal.find(params[:deal_id])
		@invoice_units = @invoice.units
		#@units_tally = @invoice_units.tallys
	end
end
