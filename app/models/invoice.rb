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

  def set_end_date(billing_cycle)
    if billing_cycle == "Daily"
      self.end_date = self.start_date + 1.day
    elsif billing_cycle == "Weekly"
      self.end_date = self.start_date + 1.week
    elsif billing_cycle == "Monthly"
      self.end_date = self.start_date + 1.month
    elsif billing_cycle == "Yearly"
      self.end_date = self.start_date + 1.year
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
