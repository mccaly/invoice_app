class Basecost
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,     type: String
  field :cost,     type: Integer
  field :quantity, type: Integer
  field :total,    type: Integer

  belongs_to :deal
  has_many   :basecost_tallys
end
