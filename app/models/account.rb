class Account < ActiveRecord::Base
  attr_accessible :name, :contact_name, :contact_email, :contact_company

  has_and_belongs_to_many :users

  has_many :invoices


end
