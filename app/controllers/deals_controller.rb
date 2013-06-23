class DealsController < ApplicationController

	def new
		@account = Account.find(params[:account_id])
		@invoice = Invoice.new
		@deal = Deal.new
	end

	def create
		process_date(params[:deal], "start_date")
		process_date(params[:deal], "end_date")
		@deal = Deal.create(params[:deal])
		

		if @deal.save
			if @deal.start_date <= Date.today
				@invoice = Invoice.create(params[:invoice])
				@invoice.start_date = @deal.start_date
				if @deal.billing_cycle == "Daily"
					@invoice.end_date = @invoice.start_date + 1.day
				elsif @deal.billing_cycle == "Weekly"
					@invoice.end_date = @invoice.start_date + 1.week
				elsif @deal.billing_cycle == "Monthly"
					@invoice.end_date = @invoice.start_date + 1.month
				elsif @deal.billing_cycle == "Yearly"
					@invoice.end_date = @invoice.start_date + 1.year
				end
				@invoice.payment_info = @deal.payment_info
				@invoice.billing_cycle = @deal.billing_cycle
				@invoice.email_invoice_approved = false
		        @invoice.email_reminder_approved = false
		        @invoice.adjust_total = 0
				@invoice.name = @deal.name
				@invoice.expected_payment_date = @invoice.end_date + (@invoice.payment_info).days
				@account = @deal.account
				@invoice.account = @account
				@invoice.account_name = @account.name
				@invoice.account_contact_name = @account.contact_name
				@invoice.account_contact_email = @account.contact_email
				user = current_user
				@invoice.user = user
				user.invoices << @invoice
				user.save
				@invoice.user_name = user.name	
				@invoice.user_contact_email = user.email				
				@invoice.deal = @deal
				@invoice.status = "Active"
				@invoice.amount = @invoice.metered_total + @invoice.basecost_total
				@invoice.save
				flash[:success] = "New Invoice created"
			end

			flash[:success] = "New Deal Created"
			redirect_to new_deal_basecost_path(@deal)
		else
			raise invoice.errors.full_messages.inspect
		end
	end

	def show
		@deal = Deal.find(params[:id])
		@account = @deal.account
		@unit = @deal.units
		@invoice = @deal.invoices
		@basecost = @deal.basecost
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
		@invoice = @deal.invoices.where(status: 'Active')
		if @deal.update_attributes(params[:deal])
			if @invoice
				@invoice.each do |invoice|
					invoice.update_attributes(name: @deal.name)
					invoice.update_attributes(payment_info: @deal.payment_info)
					invoice.save
				end
			end	
			flash[:success] = "Deal Updated"
			redirect_to deal_path(@deal)
		else
			render 'edit'
		end	
	end

	protected
	def process_date(obj, field_name)
		date = Date.new(obj["#{field_name}(1i)"].to_i, obj["#{field_name}(2i)"].to_i, obj["#{field_name}(3i)"].to_i)

		obj.delete("#{field_name}(1i)")
		obj.delete("#{field_name}(2i)")
		obj.delete("#{field_name}(3i)")

		obj[field_name] = date
    end
end
