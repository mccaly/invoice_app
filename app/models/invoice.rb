class Invoice 
	include Mongoid::Document
	include Mongoid::Timestamps


  
  field :amount, :type => Integer
  field :billing_cycle, :type => String
  field :start_date, :type => Date
  field :end_date, :type => Date
  field :name, :type => String
  field :invoice_number, :type => String
  field :payment_info, :type => Integer
  field :user_name, :type => String
  field :user_contact_email, :type => String
  field :user_company, :type => String
  field :account_name, :type => String
  field :account_contact_name, :type => String
  field :account_contact_email, :type => String
  field :status, :type => String
  field :expected_payment_date, :type => Date


  belongs_to :deal

  belongs_to :account

  has_and_belongs_to_many :units

  


# changing the status of an invoice that is ending (either because invoice end date is today or deal is ending today) & creatign new invoice if deal still has more time
  def self.create_next_invoice
    Deal.each do |deal|
      if invoice = deal.invoices.lte(end_date: Date.today).where(status: "Active") || deal.end_date < Date.today
        invoice.each do |i|
          i.update_attribute(:status, "waiting_on_payment")
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
          @invoice.payment_info = deal.payment_info
          @invoice.billing_cycle = deal.billing_cycle
          @invoice.name = deal.name
          @invoice.expected_payment_date = @invoice.end_date + (@invoice.payment_info).days
          @account = deal.account
          @invoice.account = @account
          @invoice.account_name = @account.name
          @invoice.account_contact_name = @account.contact_name
          @invoice.account_contact_email = @account.contact_email
          @user = User.find_by(:account_id == @account.id)
          @invoice.user_name = @user.name 
          @invoice.user_contact_email = @user.email       
          @invoice.deal = deal
          deal_units = deal.units
          deal_units.each do |units|
            @invoice.units << units
          end
          @invoice.status = "Active"
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
          @invoice.payment_info = deal.payment_info
          @invoice.billing_cycle = deal.billing_cycle
          @invoice.name = deal.name
          @invoice.expected_payment_date = @invoice.end_date + (@invoice.payment_info).days
          @account = deal.account
          @invoice.account = @account
          @invoice.account_name = @account.name
          @invoice.account_contact_name = @account.contact_name
          @invoice.account_contact_email = @account.contact_email
          @user = User.find_by(:account_id == @account.id)
          @invoice.user_name = @user.name 
          @invoice.user_contact_email = @user.email       
          @invoice.deal = deal
          deal_units = deal.units
          deal_units.each do |units|
            @invoice.units << units
          end
          @invoice.status = "Active"
          @invoice.save! 
      end 
    end
  end


#changing invoice status to 'overdue' if (invoice end_date + payment terms) < Date.today

  def self.change_invoice_status_to_overdue
    Invoice.each do |invoice|
        if (invoice.status == "waiting_on_payment") && (Date.today - invoice.end_date).to_i > invoice.payment_info
          invoice.update_attribute(:status, "Overdue")
        end  
    end
  end


end
