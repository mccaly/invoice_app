class Deal
	include Mongoid::Document
	include Mongoid::Timestamps

	field :name,          type: String
	field :start_date,    type: Date
	field :end_date,      type: Date
	field :billing_cycle, type: String
	field :payment_info,  type: Integer
	field :po_number,     type: String

	belongs_to :account
	has_many   :invoices
	has_many   :units
	has_many   :basecosts

	def process_deal(params, current_user)
		if self.start_date <= Date.today
	        invoice = Invoice.create(params[:invoice])
	        invoice.start_date = self.start_date
	        invoice.set_end_date(self.billing_cycle)
	        invoice.payment_info = self.payment_info
	        invoice.billing_cycle = self.billing_cycle
	        invoice.email_invoice_approved = false
            invoice.email_reminder_approved = false
            invoice.adjust_total = 0
	        invoice.name = self.name
	        invoice.expected_payment_date = invoice.end_date + (invoice.payment_info).days
	        account = self.account
	        invoice.account = account
	        invoice.account_name = account.name
	        invoice.account_contact_name = account.contact_name
	        invoice.account_contact_email = account.contact_email
	        user = current_user
	        invoice.user = user
	        user.invoices << invoice
	        user.save
	        invoice.user_name = user.name  
	        invoice.user_contact_email = user.email        
	        invoice.deal = self
	        invoice.status = "Active"
	        invoice.metered_total = invoice.unit_tallys.sum(:total).to_i
	        invoice.amount = invoice.metered_total + invoice.basecost_total
	        invoice.save
	        return true
      	end
      	return false
	end

	# changing the status of an invoice that is ending (either because invoice end date is today or deal is ending today) & creatign new invoice if deal still has more time
  def self.create_next_invoice
    Deal.each do |deal|
      if invoice = deal.invoices.lte(end_date: Date.today).where(status: "Active") || deal.end_date < Date.today
        invoice.each do |i|
          i.update_attribute(:status, "waiting_on_payment")
            basecost_tallys_invoice = i.basecost_tallys
            basecost_tallys_invoice.each do |basecost_tally|
              basecost_tally.update_attribute(:status, 'Closed')
            end
            unit_tallys_invoice = i.unit_tallys
            unit_tallys_invoice.each do |unit_tally|
              unit_tally.update_attribute(:status, 'Closed')
            end
          @user = i.user
          ApprovalMailer.invoice_email_approval(@user).deliver
        end
        if deal.end_date >= Date.today
          @invoice = Invoice.create
          @invoice.start_date = Date.today
          @invoice.set_end_date(deal.billing_cycle)

          @invoice.payment_info            = deal.payment_info
          @invoice.billing_cycle           = deal.billing_cycle
          @invoice.email_invoice_approved  = false
          @invoice.email_reminder_approved = false
          @invoice.name                    = deal.name
          @invoice.expected_payment_date   = @invoice.end_date + (@invoice.payment_info).days
          @account                         = deal.account
          @invoice.account                 = @account
          @invoice.account_name            = @account.name
          @invoice.account_contact_name    = @account.contact_name
          @invoice.account_contact_email   = @account.contact_email
          @user                            = @account.user
          @invoice.user                    = @user

          @user.invoices << @invoice
          @user.save

          @invoice.user_name               = @user.name
          @invoice.user_contact_email      = @user.email
          @invoice.deal                    = deal

          deal_units = deal.units
          deal_units.each do |unit|
            unit_tally              = UnitTally.create
            unit_tally.unit         = unit
            unit_tally.name         = unit.name
            unit_tally.access_token = unit.access_token
            unit_tally.status       = 'Active'
            unit_tally.end_date     = @invoice.end_date

            unit_tally.set(:total, unit_tally.tallys.sum(:amount_total).to_i)
            unit_tally.invoice      = @invoice
            unit_tally.save
            @invoice.unit_tallys << unit_tally
            @invoice.save
          end

          deal_basecosts = deal.basecosts
          deal_basecosts.each do |basecost|
            basecost_tally          = BasecostTally.create
            basecost_tally.basecost = basecost
            basecost_tally.name     = basecost.name
            basecost_tally.amount   = basecost.cost
            basecost_tally.quantity = basecost.quantity
              basecost_tally.set(:total, basecost_tally.amount * basecost_tally.quantity)
            basecost_tally.invoice  = @invoice
            basecost_tally.status   = 'Active'
            basecost_tally.deal     = deal
            basecost_tally.save
            deal.basecost_tallys << basecost_tally
            deal.save
            @invoice.basecost_tallys << basecost_tally
            @invoice.save
          end

          invoice_basecosts       = @invoice.basecost_tallys
          @invoice.basecost_total = invoice_basecosts.sum(:total).to_i
          invoice_units           = @invoice.unit_tallys
          @invoice.metered_total  = invoice_units.sum(:total).to_i
          @invoice.set(:amount, @invoice.basecost_total + @invoice.metered_total)
          @invoice.status         = "Active"
          @invoice.save
        end
      end
    end
  end


#checking to see if any new deals start today - if so - create new invoice
  def self.create_new_invoice_on_deal_start
    Deal.each do |deal|
      if deal.start_date == Date.today and deal.invoices.count < 1
        @invoice = Invoice.create
          @invoice.start_date = Date.today
          @invoice.set_end_date(deal.billing_cycle)

          @invoice.payment_info            = deal.payment_info
          @invoice.billing_cycle           = deal.billing_cycle
          @invoice.email_invoice_approved  = false
          @invoice.email_reminder_approved = false
          @invoice.name                    = deal.name
          @invoice.expected_payment_date   = @invoice.end_date + (@invoice.payment_info).days
          @account                         = deal.account
          @invoice.account                 = @account
          @invoice.account_name            = @account.name
          @invoice.account_contact_name    = @account.contact_name
          @invoice.account_contact_email   = @account.contact_email

          @user         = @account.user
          @invoice.user = @user
          @user.invoices << @invoice
          @user.save

          @invoice.user_name          = @user.name
          @invoice.user_contact_email = @user.email
          @invoice.deal               = deal

          deal_units = deal.units
          deal_units.each do |units|
            unit_tally = UnitTally.create
            unit_tally.name = unit.name
            unit_tally.access_token = unit.access_token
            unit_tally.status = 'Active'
            unit_tally.end_date = invoice.end_date
            unit_tally.set(:total, unit_tally.tallys.sum(:amount_total).to_i)
            unit_tally.invoice = @invoice
            unit_tally.unit = unit
            unit_tally.save
            @invoice.unit_tallys << unit_tally
            @invoice.save
          end

          deal_basecosts = deal.basecosts
          deal_basecosts.each do |basecost|
            basecost_tally          = BasecostTally.create
            basecost_tally.basecost = basecost
            basecost_tally.name     = basecost.name
            basecost_tally.amount   = basecost.cost
            basecost_tally.quantity = basecost.quantity
            basecost_tally.set(:total, basecost_tally.amount * basecost_tally.quantity)
            basecost_tally.invoice  = @invoice
            basecost_tally.status   = 'Active'
            basecost_tally.deal     = deal
            basecost_tally.save
            deal.basecost_tallys << basecost_tally
            deal.save
            @invoice.basecost_tallys << basecost_tally
            @invoice.save
          end
          invoice_basecosts       = @invoice.basecost
          @invoice.basecost_total = invoice_basecosts.sum(:total).to_i
          invoice_units           = @invoice.unit_tallys
          @invoice.metered_total  = invoice_units.sum(:total).to_i
          @invoice.set(:amount, @invoice.basecost_total + @invoice.metered_total)
          @invoice.status         = "Active"
          @invoice.save!
      end
    end
  end
end