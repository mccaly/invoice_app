class BasecostController < ApplicationController
	
	def create
		@deal = Deal.find(params[:deal_id])
		@basecost = Basecost.create(params[:basecost])
		@invoice = @deal.invoices.where(status: "Active").first
		@basecost.deal = @deal
		@deal.basecost << @base
		@deal.save
		@basecost.total = @basecost.cost * @basecost.quantity
		@basecost.save
		if @basecost.save && @invoice					
				@invoice.basecosts << @basecost
				@invoice.save
				invoice_basecosts = @invoice.basecosts
				@invoice.basecost_total = invoice_basecosts.sum(:total).to_i
				@invoice.set(:amount, @invoice.basecost_total + @invoice.metered_total)
				@invoice.save	
			flash[:success] = "New Base cost saved"

		#else
			#raise unit.errors.full_messages.inspect
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
	end

	def update
	@deal = Deal.find(params[:deal_id])
	@basecost = Basecost.find(params[:id])
	@invoice = @deal.invoices.where(status: "Active").first
	@basecost.update_attributes(params[:basecost])	
	@basecost.total = (@basecost.cost * @basecost.quantity)
	@basecost.save	
		if @invoice
			invoice_basecosts = @invoice.basecosts
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
		@invoice.inc(:amount, -@basecost.total)
		@basecost.destroy
		if @basecost.destroy
			flash[:success] = "Recurring Cost deleted"
			redirect_to deal_path(@deal)
		end
	end



end
