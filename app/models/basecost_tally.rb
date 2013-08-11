class BasecostTally
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  field :name,     type: String
  field :status,   type: String
  field :amount,   type: Integer
  field :quantity, type: Integer
  field :total,    type: Integer
  field :end_date, type:  Date

  belongs_to :invoice
  belongs_to :basecost
  belongs_to :deal
end
