class BasecostTally
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :status, :type => String
  field :amount, :type => Integer
  field :quantity, :type => Integer
  field :total, :type => Integer
  field :end_date => Date

  belongs_to :invoice
  belongs_to :basecost
  belongs_to :deal




end
