class UnitsController < ApplicationController

	def create
		account = Account.find(params[:account_id])
		invoice = Invoice.find(params[:invoice_id])
		@unit = invoice.units.build(params[:unit])
		if @unit.save
			flash[:success] = "New Unit saved"
			redirect_to account_invoice_path(account, invoice)
		else
			raise unit.errors.full_messages.inspect
		end
	end

	def new
		@unit = Units.new
		@account = Account.find(params[:account_id])
		@invoice = Invoice.find(params[:invoice_id])
	end

	def units
		@unit = Units.new
	end

end
