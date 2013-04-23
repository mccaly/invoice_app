class DealsController < ApplicationController

	def new
		@account = Account.find(params[:account_id])
		@invoice = Invoice.new
		@deal = Deal.new
	end

	def create
		@deal = Deal.create(params[:deal])
		if @deal.save
			flash[:success] = "New Deal Created"
			redirect_to new_deal_unit_path(@deal)
		else
			raise invoice.errors.full_messages.inspect
		end
	end

	def show
		@deal = Deal.find(params[:id])
		@account = @deal.account
		@unit = @deal.units
	end

	def edit
		@deal = Deal.find(params[:id])
		@account = @deal.account
	end

	def destroy
		@deal = Deal.find(params[:id])
		@account = @deal.account
		@deal.destroy
		if @deal.destroy
			flash[:success] = "Unit deleted"
			redirect_to account_path(@account.id)
		end
	end

	def update
		@deal = Deal.find(params[:id])
		if @deal.update_attributes(params[:deal])
			flash[:success] = "Deal Updated"
			redirect_to deal_path(@deal)
		else
			render 'edit'
		end	
	end
end
