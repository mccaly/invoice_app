class Invoice 
	include Mongoid::Document
	include Mongoid::Timestamps
  
  field :amount, :type => Integer
  field :billing_cycle, :type => String
  field :date_begin, :type => Date
  field :date_end, :type => Date
  field :name, :type => String
  field :number, :type => String



  belongs_to :account

  belongs_to :user

  belongs_to :deal
end
