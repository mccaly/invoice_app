class Invoice 
	include Mongoid::Document
	include Mongoid::Timestamps
  
  field :amount, :type => Integer
  field :billing_cycle, :type => String
  field :date_begin, :type => Date
  field :date_end, :type => Date
  field :name, :type => String
  field :number, :type => String
  field :status, :type => String
  field :payment_info, type => Integer


  belongs_to :deal

  has_many :units
end
