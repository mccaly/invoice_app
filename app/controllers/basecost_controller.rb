class BasecostController < ApplicationController
	
	def create
		@deal = Deal.find(params[:deal_id])
		params[:basecost][:cost] = (params[:basecost][:cost].to_f * 100).to_i	
		@basecost = Basecost.create(params[:basecost])
		@invoice = @deal.invoices.where(status: "Active").first
		@basecost.deal = @deal
		@deal.basecosts << @basecost
		@deal.save
		@basecost.total = @basecost.cost * @basecost.quantity
		@basecost.save
		if @basecost.save && @invoice
				basecost_tally = BasecostTally.create
				basecost_tally.basecost = @basecost
				basecost_tally.name = @basecost.name
				basecost_tally.amount = @basecost.cost
				basecost_tally.quantity = @basecost.quantity
				basecost_tally.set(:total, basecost_tally.amount * basecost_tally.quantity)
				basecost_tally.invoice = @invoice
				#basecost_tally.end_date = @invoice.end_date
				basecost_tally.status = 'Active'
				basecost_tally.deal = @deal
				basecost_tally.save
				@deal.basecost_tallys << basecost_tally
				@deal.save
				@invoice.basecost_tallys << basecost_tally
				invoice_basecosts = @invoice.basecost_tallys
				@invoice.basecost_total = invoice_basecosts.sum(:total).to_i
				@invoice.set(:amount, @invoice.basecost_total + @invoice.metered_total)
				@invoice.save	
			flash[:success] = "New Base cost saved"

		redirect_to new_deal_unit_path(@deal)	
		else
			redirect_to new_deal_unit_path(@deal)
		end
		
	end

	def new
		@deal = Deal.find(params[:deal_id])
		@account = @deal.account
		@basecost = Basecost.new
	end

	def edit
		@basecost = Basecost.find(params[:id])
		@amount = @basecost.cost/100.00
	end

	def update
	@deal = Deal.find(params[:deal_id])
	@basecost = Basecost.find(params[:id])
	@invoice = @deal.invoices.where(status: "Active").first
	basecost_tally = @basecost.basecost_tallys.where(status: "Active").first
	params[:basecost][:cost] = (params[:basecost][:cost].to_f * 100).to_i	
	@basecost.update_attributes(params[:basecost])	
	@basecost.total = (@basecost.cost * @basecost.quantity)
	@basecost.save	
		if basecost_tally
			basecost_tally.update_attribute(:name, @basecost.name)
			basecost_tally.update_attribute(:amount, @basecost.cost)
			basecost_tally.update_attribute(:quanitity, @basecost.quantity)
			basecost_tally.set(:total, basecost_tally.amount * basecost_tally.quantity)
			basecost_tally.save
			invoice_basecosts = @invoice.basecost_tallys
			@invoice.basecost_total = invoice_basecosts.sum(:total).to_i
			@invoice.set(:amount, @invoice.basecost_total + @invoice.metered_total)
			@invoice.save	
			flash[:success] = "Base cost Updated"
			redirect_to deal_path(@deal)
		else
			
		end	
	end


	def destroy
		@deal = Deal.find(params[:deal_id])
		@invoice = @deal.invoices.where(status: 'Active').first
		@basecost = Basecost.find(params[:id])
		basecost_tally = @basecost.basecost_tallys.where(status: "Active").first
		#@invoice.inc(:amount, -@basecost.total)
		@basecost.destroy
		if basecost_tally
			basecost_tally.destroy
			invoice_basecosts = @invoice.basecost_tallys
			@invoice.basecost_total = invoice_basecosts.sum(:total).to_i
			@invoice.set(:amount, @invoice.basecost_total + @invoice.metered_total)
			@invoice.save
			flash[:success] = "Recurring Cost deleted"
			redirect_to deal_path(@deal)
		end
	end



end
