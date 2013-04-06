class Invoice < ActiveRecord::Base
  attr_accessible :amount, :billing_cycle, :date_begin, :date_end, :name, :number, :user_id, :account_id

  belongs_to :account

  belongs_to :user
end
