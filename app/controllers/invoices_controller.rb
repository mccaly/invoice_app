class InvoicesController < ApplicationController

	def new
		@account = Account.find_by_id(params[:account_id])
		@invoice = Invoice.new
	end

	def create
		@invoice = current_user.invoices.build(params[:invoice])
		if @invoice.save
			flash[:success] = "New Invoice Created"
			redirect_to :controller => :accounts, :action => :show, :id => current_user.id
		else
			raise invoice.errors.full_messages.inspect
		end
	end

	def invoice
		@invoice = Invoice.new
	end
end
