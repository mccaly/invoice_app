class UnitsController < ApplicationController

	def create
		@deal = Deal.find(params[:deal_id])
		@unit = Unit.create(params[:unit])
		@invoice = @deal.invoices.where(status: "Active").first
		#@invoice = Invoice.find_by(@deal.id == :deal_id).where(status: "Active")
		@unit.deal = @deal
		@unit.save
		if @unit.save && @invoice != nil		
				@invoice.units << @unit
				@invoice.save

			flash[:success] = "New Unit saved"
			redirect_to deal_path(@deal)
		#else
			#raise unit.errors.full_messages.inspect
		else
			redirect_to deal_path(@deal)
		end
		
	end

	def new
		@deal = Deal.find(params[:deal_id])
		@account = @deal.account
		@unit = Unit.new
	end

	def units
		@unit = Units.new
	end

	def destroy
		@deal = Deal.find(params[:deal_id])
		@unit = Unit.find(params[:id])
		@unit.destroy
		if @unit.destroy
			flash[:success] = "Unit deleted"
			redirect_to deal_path(@deal)
		end
	end

	def edit
		@unit = Unit.find(params[:id])
	end

	def update
	@deal = Deal.find(params[:deal_id])
	@unit = Unit.find(params[:id])
	tally = Tally.where(:access_token => @unit.access_token).and(:date => Date.today).first
		if @unit.update_attributes(params[:unit])
			if tally
				tally.update_attributes(amount_unit: @unit.amount)
				tally.save
			end
			flash[:success] = "Unit Updated"
			redirect_to deal_path(@deal)
		else
			render 'edit'
		end	
	end
end
