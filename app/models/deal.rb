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
	has_many   :basecost_tallys
end