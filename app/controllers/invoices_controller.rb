class InvoicesController < ApplicationController

	def new
		@account = Account.find_by_id(params[:account_id])
		@invoice = Invoice.new
		@unit = Units.new
	end

	def create
		@account = Account.find_by_id(params[:account_id])
		@invoice = @account.invoices.build(params[:invoice])
		if @invoice.save
			flash[:success] = "New Invoice Created"
			redirect_to :controller => :accounts, :action => :show, :id => @account.id
		else
			raise invoice.errors.full_messages.inspect
		end

		@unit = @invoice.units.build(params[:unit])
		if @unit.save
			flash[:success] = "New Unit Created"
			redirect_to :controller => :invoice, :action => :show, :id => @invoice.id
		else
			raise units.errors.full_messages.inspect
		end
	end

	def invoice
		@invoice = Invoice.new
	end

	def show
		@account = Account.find_by_id(params[:account_id])
		@invoice = Invoice.find_by_id(params[:id])
	end
end
