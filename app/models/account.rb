class Account 
	include Mongoid::Document
	include Mongoid::Timestamps

  field :name, :type => String
  field :contact_name, :type => String
  field :contact_email, :type => String
  field :contact_company, :type => String




  belongs_to :user

  has_many :invoices

  has_many :deals


end
