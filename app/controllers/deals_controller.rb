class DealsController < ApplicationController

	def new
		@account = Account.find(params[:account_id])
		@invoice = Invoice.new
		@unit = Units.new
	end

	
end
