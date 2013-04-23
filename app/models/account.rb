class Account 
	include Mongoid::Document
	include Mongoid::Timestamps

  field :name, :type => String
  field :contact_name, :type => String
  field :contact_email, :type => String
  field :contact_company, :type => String




  has_and_belongs_to_many :users

  has_many :invoices

  has_many :deals


end
