class Invoice
	include Mongoid::Document
	include Mongoid::Timestamps

  field :amount,                  type: Integer
  field :basecost_total,          type: Integer, default: 0
  field :metered_total,           type: Integer, default: 0
  field :billing_cycle,           type: String
  field :start_date,              type: Date
  field :end_date,                type: Date
  field :name,                    type: String
  field :invoice_number,          type: String
  field :payment_info,            type: Integer
  field :user_name,               type: String
  field :user_contact_email,      type: String
  field :user_company,            type: String
  field :account_name,            type: String
  field :account_contact_name,    type: String
  field :account_contact_email,   type: String
  field :status,                  type: String
  field :status_closed_date,      type: Date
  field :expected_payment_date,   type: Date
  field :email_invoice_approved,  type: Boolean
  field :email_reminder_approved, type: Boolean
  field :adjust_total,            type: String, default: 'false'
  field :adjust_total_text,       type: String
  field :adjust_total_amount,     type: Integer

  belongs_to :deal
  belongs_to :account
  belongs_to :user
  has_many :basecost_tallys
  has_many :unit_tallys

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

          if deal.billing_cycle == "Daily"
            @invoice.end_date = @invoice.start_date + 1.day
          elsif deal.billing_cycle == "Weekly"
            @invoice.end_date = @invoice.start_date + 1.week
          elsif deal.billing_cycle == "Monthly"
            @invoice.end_date = @invoice.start_date + 1.month
          elsif deal.billing_cycle == "Yearly"
            @invoice.end_date = @invoice.start_date + 1.year
          end

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
          if deal.billing_cycle == "Daily"
            @invoice.end_date = @invoice.start_date + 1.day
          elsif deal.billing_cycle == "Weekly"
            @invoice.end_date = @invoice.start_date + 1.week
          elsif deal.billing_cycle == "Monthly"
            @invoice.end_date = @invoice.start_date + 1.month
          elsif deal.billing_cycle == "Yearly"
            @invoice.end_date = @invoice.start_date + 1.year
          end

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

#changing invoice status to 'overdue' if (invoice end_date + payment terms) < Date.today
  def self.change_invoice_status_to_overdue
    Invoice.each do |invoice|
      if (invoice.status == "waiting_on_payment") && (Date.today - invoice.end_date).to_i > invoice.payment_info
        invoice.update_attribute(:status, "Overdue")
        @user = invoice.user
        ApprovalMailer.reminder_email_approval(@user).deliver
      end
    end
  end
end
