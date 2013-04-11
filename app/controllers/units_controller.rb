class UnitsController < ApplicationController

	def create
		account = Account.find_by_id(params[:account_id])
		invoice = Invoice.find_by_id(params[:invoice_id])
		@unit = account.invoices.units.build(params[:unit])
		if @unit.save
			flash[:success] = "New Unit saved"
		else
			raise unit.errors.full_messages.inspect
		end
	end

	def new
		@unit = Units.new
		@account = Account.find_by_id(params[:account_id])
		@invoice = Invoice.find_by_id(params[:invoice_id])
	end

	def units
		@unit = Units.new
	end

end
